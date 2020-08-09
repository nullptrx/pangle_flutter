package io.github.nullptrx.pangleflutter.view

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.graphics.drawable.Drawable
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.view.ViewGroup.LayoutParams.WRAP_CONTENT
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import androidx.annotation.NonNull
import com.bytedance.sdk.openadsdk.TTAdConstant
import com.bytedance.sdk.openadsdk.TTAdDislike.DislikeInteractionCallback
import com.bytedance.sdk.openadsdk.TTAppDownloadListener
import com.bytedance.sdk.openadsdk.TTFeedAd
import com.bytedance.sdk.openadsdk.TTNativeAd
import com.squareup.picasso.Picasso
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.github.nullptrx.pangleflutter.R
import io.github.nullptrx.pangleflutter.util.PangleAdManager
import io.github.nullptrx.pangleflutter.util.ScreenUtil
import io.github.nullptrx.pangleflutter.util.get
import io.github.nullptrx.pangleflutter.util.px
import java.net.HttpURLConnection
import java.net.URL
import java.util.*


class FlutterFeedView(
    val context: Context,
    messenger: BinaryMessenger,
    val id: Int,
    params: Map<String, Any?>
) : PlatformView, MethodChannel.MethodCallHandler, DislikeInteractionCallback {

  companion object {
    private val ttAppDownloadListenerMap = WeakHashMap<AdViewHolder, TTAppDownloadListener>()
    private val ttFeedAdMap = mutableMapOf<Int, TTFeedAd>()
  }

  var activity: Activity? = null

  private val methodChannel: MethodChannel
  private val container: FrameLayout
  private var feedId: String? = null


  init {

    methodChannel = MethodChannel(messenger, "nullptrx.github.io/pangle_feedview_$id")
    methodChannel.setMethodCallHandler(this)

    activity = scanForActivity(context)

    container = FrameLayout(context)
    container.layoutParams = ViewGroup.LayoutParams(MATCH_PARENT, WRAP_CONTENT)

    val feedId = params["feedId"] as? String
    this.feedId = feedId
    feedId?.also {
      val ttFeedAd: TTFeedAd? = PangleAdManager.shared.getFeedAd(it)
      loadAd(ttFeedAd)
    }


  }

  override fun getView(): View {
    return container
  }

  override fun dispose() {
    methodChannel.setMethodCallHandler(null)
    container.removeAllViews()
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "update" -> {
        invalidateView()
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }

  private fun scanForActivity(cont: Context?): Activity? {
    var context = cont
    while (context is ContextWrapper) {
      if (context is Activity) {
        return context
      }
      context = context.baseContext
    }
    return null
  }

  private fun invalidateView() {
    this.feedId ?: return
    val ttFeedAd: TTFeedAd? = PangleAdManager.shared.getFeedAd(this.feedId!!)
    loadAd(ttFeedAd)
  }

  private fun removeView() {
    this.feedId?.also {
      PangleAdManager.shared.removeFeedAd(it)
    }
    methodChannel.invokeMethod(Method.remove.name, null)
    container.removeAllViews()
  }

  private fun loadImage(url: String): Drawable? {
    try {
      val imgUrl = URL(url)
      val conn: HttpURLConnection = imgUrl.openConnection() as HttpURLConnection
      conn.doInput = true
      conn.connect()
      val drawable = Drawable.createFromStream(conn.inputStream, url.hashCode().toString())
      return drawable
    } catch (e: Exception) {
    }
    return null
  }

  internal enum class Method {
    remove,
    update;
  }


  fun loadAd(ad: TTFeedAd?) {
    if (ad == null) {
      return
    }
    container.removeAllViews()
//    val adView = ad.adView
    val view = when (ad.imageMode) {
      TTAdConstant.IMAGE_MODE_SMALL_IMG -> bindSmallAdView(container, ad)
      TTAdConstant.IMAGE_MODE_LARGE_IMG -> bindLargeAdView(container, ad)
      TTAdConstant.IMAGE_MODE_GROUP_IMG -> bindGroupAdView(container, ad)
      TTAdConstant.IMAGE_MODE_VIDEO -> bindVideoView(container, ad)
      TTAdConstant.IMAGE_MODE_VERTICAL_IMG -> bindVerticalAdView(container, ad)
      else -> null
    }
    if (view == null) {
      return
    }


    val screenSize = ScreenUtil.getScreenSize()
    val sw = screenSize.width.toFloat()
    val sh = screenSize.height.toFloat()
    val feedHeight: Float
    if (sw > sh) {
      val feedHeightPercent: Float = when (ad.imageMode) {
        TTAdConstant.IMAGE_MODE_SMALL_IMG -> 0.175f // 140.dp
        TTAdConstant.IMAGE_MODE_LARGE_IMG -> 0.68f // 310.dp
        TTAdConstant.IMAGE_MODE_GROUP_IMG -> 0.3483f // 180.dp
        TTAdConstant.IMAGE_MODE_VIDEO -> 0.68f // 310.dp
        TTAdConstant.IMAGE_MODE_VERTICAL_IMG -> 0.001f // 1
        else -> 0.001f // 1
      }
      feedHeight = sw * feedHeightPercent
    } else {
      val feedHeightPercent: Float = when (ad.imageMode) {
        TTAdConstant.IMAGE_MODE_SMALL_IMG -> 0.3565f // 140.dp
        TTAdConstant.IMAGE_MODE_LARGE_IMG -> 0.7898f // 310.dp
        TTAdConstant.IMAGE_MODE_GROUP_IMG -> 0.4583f // 180.dp
        TTAdConstant.IMAGE_MODE_VIDEO -> 0.7898f // 310.dp
        TTAdConstant.IMAGE_MODE_VERTICAL_IMG -> 0.001f // 1
        else -> 0.001f // 1
      }
      feedHeight = sw * feedHeightPercent
    }

    container.apply {
      val params = FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT)
      params.gravity = Gravity.CENTER
      addView(view, params)
      layoutParams = layoutParams.also {
        it.width = sw.toInt()
        it.height = feedHeight.toInt()
      }
      invoke(sw.px, feedHeight.px)
    }
  }

  private fun invoke(width: Float, height: Float) {
    val params = mutableMapOf<String, Any>()
    params["width"] = width
    params["height"] = height
    methodChannel.invokeMethod(Method.update.name, params)
  }

  private fun bindSmallAdView(parent: ViewGroup, @NonNull ad: TTFeedAd): View {
    val holder = SmallAdViewHolder()
    val view = LayoutInflater.from(context).inflate(R.layout.pangle_flutter_item_small_pic, parent, false)
    holder.title = view[R.id.pangle_flutter_item_title]
    holder.description = view[R.id.pangle_flutter_item_desc]
    holder.source = view[R.id.pangle_flutter_item_source]
    holder.smallImage = view[R.id.pangle_flutter_item_image]
    holder.icon = view[R.id.pangle_flutter_item_icon]
    holder.dislike = view[R.id.pangle_flutter_item_dislike]
    holder.creativeButton = view[R.id.pangle_flutter_item_creative]
    holder.stopButton = view[R.id.pangle_flutter_item_stop]
    holder.removeButton = view[R.id.pangle_flutter_item_remove]

    bindData(container, holder, ad)
    if (ad.imageList != null && !ad.imageList.isEmpty()) {
      val image = ad.imageList[0]
      if (image != null && image.isValid && holder.smallImage != null) {
        Picasso.get().load(image.imageUrl).into(holder.smallImage)
      }
    }
    return view
  }


  /**
   * @param convertView
   * @param parent
   * @param ad
   * @return
   */
  private fun bindVerticalAdView(parent: ViewGroup, @NonNull ad: TTFeedAd): View {

    val holder = VerticalAdViewHolder()
    // 未找到模板素材，暂时使用 small pic 布局
    val view = LayoutInflater.from(context).inflate(R.layout.pangle_flutter_item_small_pic, parent, false)
//    val view = LayoutInflater.from(context).inflate(R.layout.pangle_flutter_listitem_ad_vertical_pic, parent, false)
    holder.title = view[R.id.pangle_flutter_item_title]
    holder.description = view[R.id.pangle_flutter_item_desc]
    holder.source = view[R.id.pangle_flutter_item_source]
    holder.verticalImage = view[R.id.pangle_flutter_item_image]
    holder.icon = view[R.id.pangle_flutter_item_icon]
    holder.dislike = view[R.id.pangle_flutter_item_dislike]
    holder.creativeButton = view[R.id.pangle_flutter_item_creative]
    holder.stopButton = view[R.id.pangle_flutter_item_stop]
    holder.removeButton = view[R.id.pangle_flutter_item_remove]

    bindData(container, holder, ad)
    if (ad.imageList != null && !ad.imageList.isEmpty()) {
      val image = ad.imageList[0]
      if (image != null && image.isValid && holder.verticalImage != null) {
        Picasso.get().load(image.imageUrl).into(holder.verticalImage)
      }
    }
    return view
  }

  private fun bindLargeAdView(parent: ViewGroup, @NonNull ad: TTFeedAd): View {

    val holder = LargeAdViewHolder()
    val view = LayoutInflater.from(context).inflate(R.layout.pangle_flutter_item_large_pic, parent, false)
    holder.title = view[R.id.pangle_flutter_item_title]
    holder.description = view[R.id.pangle_flutter_item_desc]
    holder.source = view[R.id.pangle_flutter_item_source]
    holder.largeImage = view[R.id.pangle_flutter_item_image]
    holder.icon = view[R.id.pangle_flutter_item_icon]
    holder.dislike = view[R.id.pangle_flutter_item_dislike]
    holder.creativeButton = view[R.id.pangle_flutter_item_creative]
    holder.stopButton = view[R.id.pangle_flutter_item_stop]
    holder.removeButton = view[R.id.pangle_flutter_item_remove]

    bindData(container, holder, ad)
    if (ad.imageList != null && !ad.imageList.isEmpty()) {
      val image = ad.imageList[0]
      if (image != null && image.isValid && holder.largeImage != null) {
        Picasso.get().load(image.imageUrl).into(holder.largeImage)

      }
    }
    return view
  }

  private fun bindGroupAdView(parent: ViewGroup, @NonNull ad: TTFeedAd): View {

    val holder = GroupAdViewHolder()
    val view = LayoutInflater.from(context).inflate(R.layout.pangle_flutter_item_group_pic, parent, false)
    holder.title = view[R.id.pangle_flutter_item_title]
    holder.description = view[R.id.pangle_flutter_item_desc]
    holder.source = view[R.id.pangle_flutter_item_source]
    holder.groupImage1 = view[R.id.pangle_flutter_item_image1]
    holder.groupImage2 = view[R.id.pangle_flutter_item_image2]
    holder.groupImage3 = view[R.id.pangle_flutter_item_image3]
    holder.icon = view[R.id.pangle_flutter_item_icon]
    holder.dislike = view[R.id.pangle_flutter_item_dislike]
    holder.creativeButton = view[R.id.pangle_flutter_item_creative]
    holder.stopButton = view[R.id.pangle_flutter_item_stop]
    holder.removeButton = view[R.id.pangle_flutter_item_remove]

    bindData(container, holder, ad)
    if (ad.imageList != null && ad.imageList.size >= 3) {
      val image1 = ad.imageList[0]
      val image2 = ad.imageList[1]
      val image3 = ad.imageList[2]
      if (image1 != null && image1.isValid && holder.groupImage1 != null) {
        Picasso.get().load(image1.imageUrl).into(holder.groupImage1)
      }
      if (image2 != null && image2.isValid && holder.groupImage2 != null) {
        Picasso.get().load(image2.imageUrl).into(holder.groupImage2)
      }
      if (image3 != null && image3.isValid && holder.groupImage3 != null) {
        Picasso.get().load(image3.imageUrl).into(holder.groupImage3)
      }
    }
    return view
  }


  /**
   * 渲染视频广告，以视频广告为例，以下说明
   */
  private fun bindVideoView(parent: ViewGroup, ad: TTFeedAd): View {
    val holder = VideoAdViewHolder()
    val view = LayoutInflater.from(context).inflate(R.layout.pangle_flutter_item_large_video, parent, false)
    holder.title = view[R.id.pangle_flutter_item_title]
    holder.description = view[R.id.pangle_flutter_item_desc]
    holder.source = view[R.id.pangle_flutter_item_source]
    holder.videoView = view[R.id.pangle_flutter_item_video]
    holder.icon = view[R.id.pangle_flutter_item_icon]
    holder.dislike = view[R.id.pangle_flutter_item_dislike]
    holder.creativeButton = view[R.id.pangle_flutter_item_creative]
    holder.stopButton = view[R.id.pangle_flutter_item_stop]
    holder.removeButton = view[R.id.pangle_flutter_item_remove]

    bindData(parent, holder, ad)
    val video = ad.adView
    if (video != null && video.parent == null) {
      holder.videoView?.apply {
        removeAllViews()
        addView(video)
      }
    }
    return view
  }


  private fun bindData(convertView: ViewGroup, holder: AdViewHolder, ad: TTFeedAd) {
    //设置dislike弹窗，这里展示自定义的dialog
    holder.dislike?.also {
      bindDislikeCustom(convertView, it, ad)
    }

    //可以被点击的view, 也可以把convertView放进来意味item可被点击
    val clickViewList: MutableList<View> = ArrayList()
    clickViewList.add(convertView)
    //触发创意广告的view（点击下载或拨打电话）
    val creativeViewList: MutableList<View> = ArrayList()
    holder.creativeButton?.also {
      creativeViewList.add(it)
    }
    //如果需要点击图文区域也能进行下载或者拨打电话动作，请将图文区域的view传入
//            creativeViewList.add(convertView);
    //重要! 这个涉及到广告计费，必须正确调用。convertView必须使用ViewGroup。
    ad.registerViewForInteraction(convertView, clickViewList, creativeViewList, object : TTNativeAd.AdInteractionListener {
      override fun onAdClicked(view: View, ad: TTNativeAd) {
      }

      override fun onAdCreativeClick(view: View, ad: TTNativeAd) {
      }

      override fun onAdShow(ad: TTNativeAd) {
      }
    })
    holder.title?.text = ad.title //title为广告的简单信息提示
    holder.description?.text = ad.description //description为广告的较长的说明
    // 广告来源
    holder.source?.text = if (ad.source == null) "" else ad.source
    val icon = ad.icon
//    holder.icon?.setImageBitmap(icon)
    if (icon != null && icon.isValid && holder.icon != null) {
      Picasso.get().load(icon.imageUrl).into(holder.icon)
    }
    val adCreativeButton: Button? = holder.creativeButton
    when (ad.interactionType) {
      TTAdConstant.INTERACTION_TYPE_DOWNLOAD -> {
        //如果初始化ttAdManager.createAdNative(getApplicationContext())没有传入activity 则需要在此传activity，否则影响使用Dislike逻辑
        activity?.let {
          ad.setActivityForDownloadApp(it)
        }
        holder.stopButton?.visibility = View.VISIBLE
        holder.removeButton?.visibility = View.VISIBLE
        adCreativeButton?.also {
          adCreativeButton.visibility = View.VISIBLE
          bindDownloadListener(adCreativeButton, holder, ad)
        }
        //绑定下载状态控制器
        bindDownLoadStatusController(holder, ad)
      }
      TTAdConstant.INTERACTION_TYPE_DIAL -> {
        adCreativeButton?.visibility = View.VISIBLE
        adCreativeButton?.text = "立即拨打"
        holder.stopButton?.visibility = View.GONE
        holder.removeButton?.visibility = View.GONE
      }
      TTAdConstant.INTERACTION_TYPE_LANDING_PAGE, TTAdConstant.INTERACTION_TYPE_BROWSER -> {
        //                    adCreativeButton.setVisibility(View.GONE);
        adCreativeButton?.visibility = View.VISIBLE
        adCreativeButton?.text = "查看详情"
        holder.stopButton?.visibility = View.GONE
        holder.removeButton?.visibility = View.GONE
      }
      else -> {
        adCreativeButton?.visibility = View.GONE
        holder.stopButton?.visibility = View.GONE
        holder.removeButton?.visibility = View.GONE
      }
    }
  }


  private fun bindDislikeCustom(convertView: ViewGroup, dislike: View, ad: TTFeedAd) {
    dislike.setOnClickListener {
      ad.getDislikeDialog(activity)?.apply {
        setDislikeInteractionCallback(this@FlutterFeedView)
        showDislikeDialog()
      }
    }

  }

  override fun onSelected(position: Int, value: String) {
//      val id = id
    removeView()
  }

  override fun onCancel() {}
  override fun onRefuse() {}

  private fun bindDownloadListener(adCreativeButton: Button, adViewHolder: AdViewHolder, ad: TTFeedAd) {
    val downloadListener: TTAppDownloadListener = object : TTAppDownloadListener {
      override fun onIdle() {
        if (!isValid) {
          return
        }
        adCreativeButton.text = "开始下载"
        adViewHolder.stopButton?.text = "开始下载"
      }

      @SuppressLint("SetTextI18n")
      override fun onDownloadActive(totalBytes: Long, currBytes: Long, fileName: String, appName: String) {
        if (!isValid) {
          return
        }
        if (totalBytes <= 0L) {
          adCreativeButton.text = "0%"
        } else {
          adCreativeButton.text = (currBytes * 100 / totalBytes).toString() + "%"
        }
        adViewHolder.stopButton?.text = "下载中"
      }

      @SuppressLint("SetTextI18n")
      override fun onDownloadPaused(totalBytes: Long, currBytes: Long, fileName: String, appName: String) {
        if (!isValid) {
          return
        }
        if (totalBytes <= 0L) {
          adCreativeButton.text = "0%"
        } else {
          adCreativeButton.text = (currBytes * 100 / totalBytes).toString() + "%"
        }
        adViewHolder.stopButton?.text = "下载暂停"
      }

      override fun onDownloadFailed(totalBytes: Long, currBytes: Long, fileName: String, appName: String) {
        if (!isValid) {
          return
        }
        adCreativeButton.text = "重新下载"
        adViewHolder.stopButton?.text = "重新下载"
      }

      override fun onInstalled(fileName: String, appName: String) {
        if (!isValid) {
          return
        }
        adCreativeButton.text = "点击打开"
        adViewHolder.stopButton?.text = "点击打开"
      }

      override fun onDownloadFinished(totalBytes: Long, fileName: String, appName: String) {
        if (!isValid) {
          return
        }
        adCreativeButton.text = "点击安装"
        adViewHolder.stopButton?.text = "点击安装"
      }

      private val isValid: Boolean
        get() = ttAppDownloadListenerMap.get(adViewHolder) === this
    }
    //一个ViewHolder对应一个downloadListener, isValid判断当前ViewHolder绑定的listener是不是自己
    ad.setDownloadListener(downloadListener) // 注册下载监听器
    ttAppDownloadListenerMap[adViewHolder] = downloadListener
  }


  private fun bindDownLoadStatusController(adViewHolder: AdViewHolder, ad: TTFeedAd) {
    val controller = ad.downloadStatusController
    adViewHolder.stopButton?.setOnClickListener {
      controller?.changeDownloadStatus()
    }
    adViewHolder.removeButton?.setOnClickListener {
      controller?.cancelDownload()
    }
  }

  internal open class AdViewHolder {
    var icon: ImageView? = null
    var dislike: ImageView? = null
    var creativeButton: Button? = null
    var title: TextView? = null
    var description: TextView? = null
    var source: TextView? = null
    var stopButton: Button? = null
    var removeButton: Button? = null
  }

  internal class VideoAdViewHolder : AdViewHolder() {
    var videoView: FrameLayout? = null
  }

  internal class LargeAdViewHolder : AdViewHolder() {
    var largeImage: ImageView? = null
  }

  internal class SmallAdViewHolder : AdViewHolder() {
    var smallImage: ImageView? = null
  }

  internal class VerticalAdViewHolder : AdViewHolder() {
    var verticalImage: ImageView? = null
  }

  internal class GroupAdViewHolder : AdViewHolder() {
    var groupImage1: ImageView? = null
    var groupImage2: ImageView? = null
    var groupImage3: ImageView? = null
  }


}