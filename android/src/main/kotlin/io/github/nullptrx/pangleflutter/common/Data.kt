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

// ---------------------------------------------------------------------------
// Error codes / messages returned to Dart via result callbacks.
// Use these constants instead of bare string literals so that callers can do
// reliable programmatic checks (e.g. `if (code == ERROR_CODE_ACTIVITY_DESTROYED)`).
// ---------------------------------------------------------------------------

/** Activity is null — not yet bound, already detached, or otherwise unavailable. */
const val ERROR_CODE_NO_ACTIVITY = -100
const val ERROR_MSG_NO_ACTIVITY = "ERROR_NO_ACTIVITY"
