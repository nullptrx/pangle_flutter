package io.github.nullptrx.pangleflutter.common

data class TTSize(
    val width: Int = 0,
    val height: Int = 0
)

data class TTSizeF(
    val width: Float = 0f,
    val height: Float = 0f

)

val kBlock: (Any) -> Unit = {}