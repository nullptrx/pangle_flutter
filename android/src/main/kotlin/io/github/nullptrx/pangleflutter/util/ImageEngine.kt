package io.github.nullptrx.pangleflutter.util

import android.content.Context
import io.github.nullptrx.pangleflutter.util.imageloader.ImageLoader

object ImageEngine {
  private var imageLoader: ImageLoader? = null

  fun getInstance(context: Context?): ImageLoader {
    if (imageLoader == null) {
      synchronized(this) {
        if (imageLoader == null) {
          imageLoader = ImageLoader.build(context?.applicationContext)
        }
      }
    }
    return imageLoader!!
  }
}