package com.sajat.ipkamera
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.IOException
object OnvifPtzController {
    private val client = OkHttpClient()
    fun move(onvifUrl: String, profileToken: String, x: Float, y: Float, onResult: (Boolean) -> Unit) {
        if (onvifUrl.isBlank()) { onResult(false); return }
        val soapBody = """
            <?xml version="1.0" encoding="utf-8"?>
            <s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope">
              <s:Body>
                <ContinuousMove xmlns="http://www.onvif.org/ver20/ptz/wsdl">
                  <ProfileToken>$profileToken</ProfileToken>
                  <Velocity><PanTilt x="$x" y="$y" xmlns="http://www.onvif.org/ver10/schema"/></Velocity>
                </ContinuousMove>
              </s:Body>
            </s:Envelope>
        """.trimIndent()
        val request = Request.Builder().url(onvifUrl).post(soapBody.toRequestBody("application/soap+xml; charset=utf-8".toMediaType())).build()
        client.newCall(request).enqueue(object : okhttp3.Callback {
            override fun onFailure(call: okhttp3.Call, e: IOException) { onResult(false) }
            override fun onResponse(call: okhttp3.Call, response: okhttp3.Response) {
                response.close()
                Thread.sleep(400)
                stop(onvifUrl, profileToken)
                onResult(true)
            }
        })
    }
    private fun stop(onvifUrl: String, profileToken: String) {
        val stopBody = """
            <?xml version="1.0" encoding="utf-8"?>
            <s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope">
              <s:Body>
                <Stop xmlns="http://www.onvif.org/ver20/ptz/wsdl">
                  <ProfileToken>$profileToken</ProfileToken><PanTilt>true</PanTilt><Zoom>false</Zoom>
                </Stop>
              </s:Body>
            </s:Envelope>
        """.trimIndent()
        val request = Request.Builder().url(onvifUrl).post(stopBody.toRequestBody("application/soap+xml; charset=utf-8".toMediaType())).build()
        try { client.newCall(request).execute().close() } catch (_: Exception) { }
    }
}
