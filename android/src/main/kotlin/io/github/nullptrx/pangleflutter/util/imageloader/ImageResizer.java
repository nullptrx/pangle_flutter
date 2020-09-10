package io.github.nullptrx.pangleflutter.util.imageloader;

import java.io.FileDescriptor;

import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

public class ImageResizer {
	private static final String TAG = "ImageResizer";

	public ImageResizer() {
		super();
		// TODO Auto-generated constructor stub
	}

	public Bitmap decodeSampledBitmapFromResource(Resources res, int resId,
			int reqWidth, int reqHeight) {
		final BitmapFactory.Options options = new BitmapFactory.Options();
		options.inJustDecodeBounds = true;
		BitmapFactory.decodeResource(res, resId, options);

		options.inSampleSize = calculateInSampleSize(options, reqWidth,
				reqHeight);

		options.inJustDecodeBounds = false;
		return BitmapFactory.decodeResource(res, resId, options);
	}
	
	public Bitmap decodeSampledBitmapFromBitmapFileDescriptor(FileDescriptor fd,
			int reqWidth,int reqHeight){
		final BitmapFactory.Options options = new BitmapFactory.Options();
		options.inJustDecodeBounds = true;
	
		BitmapFactory.decodeFileDescriptor(fd, null, options);
		
		options.inSampleSize = calculateInSampleSize(options, reqWidth,
				reqHeight);

		options.inJustDecodeBounds = false;
		return BitmapFactory.decodeFileDescriptor(fd, null, options);
	}
	
	
	
	

	public int calculateInSampleSize(BitmapFactory.Options options,
			int reqWidth, int reqHeight) {

		final int width = options.outWidth;
		final int height = options.outHeight;

		int inSampleSize = 1;
		if (height > reqHeight || width > reqWidth) {
			final int halfHeight = height / 2;
			final int halfWidth = width / 2;
			while ((halfHeight / inSampleSize) > reqHeight
					&& (halfWidth / inSampleSize) > halfWidth) {
				inSampleSize *= 2;
			}
		}
		return inSampleSize;

	}

}
