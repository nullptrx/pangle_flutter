package io.github.nullptrx.pangleflutter.util.imageloader;

import android.Manifest;
import android.annotation.TargetApi;
import android.app.ActivityManager;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Build;
import android.os.Build.VERSION_CODES;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.os.StatFs;
import android.util.Log;
import android.util.LruCache;
import android.widget.ImageView;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileDescriptor;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.concurrent.Executor;
import java.util.concurrent.LinkedBlockingDeque;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

import io.github.nullptrx.pangleflutter.R;

public class ImageLoader {

  private static final String TAG = "ImageLoader";

  public static final int MESSAGE_POST_RESULT = 1;

  private static final int CPU_COUNT = Runtime.getRuntime()
      .availableProcessors();

  private static final int CORE_POOL_SIZE = CPU_COUNT + 1;
  private static final int MAXIMUM_POOL_SIZE = CPU_COUNT * 2 + 1;
  private static final long KEEP_ALIVE = 10L;

  private static final int TAG_KEY_URI = R.id.pangle_flutter_imageloader_uri;
  private static final long DISK_CACHE_SIZE = 1024 * 1024 * 50;
  private static final int IO_BUFFER_SIZE = 8 * 1024;
  private static final int DISK_CACHE_INDEX = 0;
  private boolean mIsDiskLruCacheCreated = false;

  private static final ThreadFactory sThreadFactory = new ThreadFactory() {
    private final AtomicInteger mCount = new AtomicInteger();

    @Override
    public Thread newThread(Runnable r) {
      // TODO Auto-generated method stub
      return new Thread(r, "ImageLoader#" + mCount.getAndIncrement());
    }
  };

  public static final Executor THREAD_POOL_EXECUTOR = new ThreadPoolExecutor(
      CORE_POOL_SIZE, MAXIMUM_POOL_SIZE, KEEP_ALIVE, TimeUnit.SECONDS,
      new LinkedBlockingDeque<Runnable>(), sThreadFactory);

  private Handler mMainHandler = new Handler(Looper.getMainLooper()) {

    @Override
    public void handleMessage(Message msg) {
      LoaderResult result = (LoaderResult) msg.obj;
      ImageView imageView = result.imageView;
      imageView.setImageBitmap(result.bitmap);
      String uri = (String) imageView.getTag(TAG_KEY_URI);
      if (uri.equals(result.uri)) {
        imageView.setImageBitmap(result.bitmap);
      } else {
        Log.w(TAG, "set image bitmap,but url has changed , ignored!");
      }
    }

  };

  private Context mContext;
  private ImageResizer mImageResizer = new ImageResizer();
  private LruCache<String, Bitmap> mMemoryCache;
  private DiskLruCache mDiskLruCache;

  public ImageLoader(Context context) {
    mContext = context.getApplicationContext();
    // 分配内存缓存为当前进程的1/8,磁盘缓存容量为50M
    ActivityManager am = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
    ActivityManager.MemoryInfo mi = new ActivityManager.MemoryInfo();
    am.getMemoryInfo(mi);
//        int maxMemory = (int) (Runtime.getRuntime().maxMemory() * 1024);
    int maxMemory = (int) (mi.availMem);
    int cacheSize = maxMemory / 8;
    mMemoryCache = new LruCache<String, Bitmap>(cacheSize) {

      @Override
      protected int sizeOf(String key, Bitmap value) {
        return value.getRowBytes() * value.getHeight() / 1024;
      }

    };

    File diskCacheDir = getDiskChaheDir(mContext, "bitmap");
    if (!diskCacheDir.exists()) {
      diskCacheDir.mkdirs();
    }
    if (getUsableSpace(diskCacheDir) > DISK_CACHE_SIZE) {
      try {
        mDiskLruCache = DiskLruCache.open(diskCacheDir, 1, 1,
            DISK_CACHE_SIZE);
        mIsDiskLruCacheCreated = true;
      } catch (IOException e) {
        e.printStackTrace();
      }
    }
  }

  public static ImageLoader build(Context context) {
    return new ImageLoader(context);
  }

  private void addBitmapToMemoryCache(String key, Bitmap bitmap) {
    if (getBitmapFromMemCache(key) == null) {
      mMemoryCache.put(key, bitmap);
    }
  }

  private Bitmap getBitmapFromMemCache(String key) {
    return mMemoryCache.get(key);
  }

  public void bindBitmap(final String uri, final ImageView imageView) {
    bindBitmap(uri, imageView, 0, 0);
  }

  // 异步加载
  public void bindBitmap(final String uri, final ImageView imageView,
                         final int reqWidth, final int reqHeight) {

    imageView.setTag(TAG_KEY_URI, uri);
    Bitmap bitmap = loadBitmpaFromMemCache(uri);
    if (bitmap != null) {
      imageView.setImageBitmap(bitmap);
      return;
    }
    Runnable loadBitmapTask = new Runnable() {

      @Override
      public void run() {
        Bitmap bitmap = loadBitmap(uri, reqWidth, reqHeight);
        if (bitmap != null) {
          LoaderResult result = new LoaderResult(imageView, uri,
              bitmap);
          mMainHandler.obtainMessage(MESSAGE_POST_RESULT, result)
              .sendToTarget();

        }
      }
    };
    THREAD_POOL_EXECUTOR.execute(loadBitmapTask);
  }

  // 同步加载
  public Bitmap loadBitmap(String uri, int reqWidth, int reqHeight) {
    Bitmap bitmap = loadBitmpaFromMemCache(uri);
    if (bitmap != null) {
      return bitmap;
    }
    try {
      bitmap = loadBitmapForDiskCache(uri, reqWidth, reqHeight);
      if (bitmap != null) {
        return bitmap;
      }
      bitmap = loadBitmapFromHttp(uri, reqWidth, reqHeight);

    } catch (IOException e) {
      e.printStackTrace();
    }
    if (bitmap == null && !mIsDiskLruCacheCreated) {
      bitmap = downloadBitmapFromUrl(uri);
    }
    return bitmap;
  }

  private Bitmap loadBitmpaFromMemCache(String url) {
    final String key = hashKeyFormUrl(url);
    Bitmap bitmap = getBitmapFromMemCache(key);
    return bitmap;
  }

  // 将下载的图片写入文件系统，实现磁盘缓存
  private Bitmap loadBitmapFromHttp(String url, int reqWidth, int reqHeight)
      throws IOException {
    if (Looper.myLooper() == Looper.getMainLooper()) {
      throw new RuntimeException("can not visit network from UI Thread.");
    }
    if (mDiskLruCache == null)
      return null;
    String key = hashKeyFormUrl(url);
    DiskLruCache.Editor editor = mDiskLruCache.edit(key);
    if (editor != null) {
      OutputStream outputStream = editor.newOutputStream(DISK_CACHE_INDEX);
      if (downloadUrlToStream(url, outputStream)) {
        editor.commit();
      } else {
        editor.abort();
      }

    }
    mDiskLruCache.flush();
    return loadBitmapForDiskCache(url, reqWidth, reqHeight);
  }

  //
  private Bitmap loadBitmapForDiskCache(String url, int reqWidth, int reqHeight)
      throws IOException {
    if (Looper.myLooper() == Looper.getMainLooper()) {
      Log.w(TAG, "load bitmap from UI Thread , it's not recommended");
    }
    if (mDiskLruCache == null)
      return null;
    Bitmap bitmap = null;
    String key = hashKeyFormUrl(url);
    DiskLruCache.Snapshot snapshot = mDiskLruCache.get(key);
    if (snapshot != null) {
      FileInputStream fileInputStream = (FileInputStream) snapshot
          .getInputStream(DISK_CACHE_INDEX);
      FileDescriptor fileDescriptor = fileInputStream.getFD();
      bitmap = mImageResizer.decodeSampledBitmapFromBitmapFileDescriptor(
          fileDescriptor, reqWidth, reqHeight);
      if (bitmap != null) {
        addBitmapToMemoryCache(key, bitmap);
      }
    }
    return bitmap;
  }

  public boolean downloadUrlToStream(String urlString,
                                     OutputStream outputStream) {
    HttpURLConnection urlConnection = null;
    BufferedOutputStream out = null;
    BufferedInputStream in = null;
    try {
      final URL url = new URL(urlString);
      urlConnection = (HttpURLConnection) url.openConnection();
      in = new BufferedInputStream(urlConnection.getInputStream(),
          IO_BUFFER_SIZE);
      out = new BufferedOutputStream(outputStream, IO_BUFFER_SIZE);

      int b;
      while ((b = in.read()) != -1) {
        out.write(b);
      }
      return true;
    } catch (Exception e) {
      Log.e(TAG, "downloadBitmap failed ." + e);
    } finally {
      if (urlConnection != null)
        urlConnection.disconnect();
      StreamUtils.close(out);
      StreamUtils.close(in);
    }
    return false;
  }

  private Bitmap downloadBitmapFromUrl(String urlString) {
    Bitmap bitmap = null;
    HttpURLConnection urlConnection = null;
    BufferedInputStream in = null;
    try {
      final URL url = new URL(urlString);
      urlConnection = (HttpURLConnection) url.openConnection();
      in = new BufferedInputStream(urlConnection.getInputStream(),
          IO_BUFFER_SIZE);
      bitmap = BitmapFactory.decodeStream(in);
    } catch (Exception e) {
      // TODO: handle exception
      Log.e(TAG, "Error in downloadBitmap:" + e);
    } finally {
      if (urlConnection != null)
        urlConnection.disconnect();
      StreamUtils.close(in);
    }
    return bitmap;
  }

  private String hashKeyFormUrl(String url) {
    String cacheKey;
    try {
      final MessageDigest mDigest = MessageDigest.getInstance("MD5");
      mDigest.update(url.getBytes());
      cacheKey = bytesToHexString(mDigest.digest());
    } catch (NoSuchAlgorithmException e) {
      cacheKey = String.valueOf(url.hashCode());
    }
    return cacheKey;
  }

  private String bytesToHexString(byte[] bytes) {
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < bytes.length; i++) {
      String hex = Integer.toHexString(0xFF & bytes[i]);
      if (hex.length() == 1) {
        sb.append('0');
      }
      sb.append(hex);
    }
    return sb.toString();
  }

  public File getDiskChaheDir(Context context, String uniqueName) {
    boolean externalStorageAvailable = externalStorageAvailable = Environment
        .getExternalStorageState()
        .equals(Environment.MEDIA_MOUNTED);
    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
      externalStorageAvailable = externalStorageAvailable &&
          context.checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED;
    }
    final String cachePath;
    if (externalStorageAvailable) {
      cachePath = context.getExternalCacheDir().getPath();
    } else {
      cachePath = context.getCacheDir().getPath();
    }
    return new File(cachePath + File.separator + uniqueName);
  }

  @TargetApi(VERSION_CODES.GINGERBREAD)
  private long getUsableSpace(File path) {
    if (Build.VERSION.SDK_INT >= VERSION_CODES.GINGERBREAD) {
      return path.getUsableSpace();
    }
    final StatFs stats = new StatFs(path.getPath());
    return (long) stats.getBlockSize() * (long) stats.getAvailableBlocks();
  }

  private static class LoaderResult {
    public ImageView imageView;
    public String uri;
    public Bitmap bitmap;

    private LoaderResult(ImageView imageView, String uri, Bitmap bitmap) {
      super();
      this.imageView = imageView;
      this.uri = uri;
      this.bitmap = bitmap;
    }

  }
}
