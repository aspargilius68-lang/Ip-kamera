package com.sajat.ipkamera
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.os.Bundle
import android.view.TextureView
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.Toast
import androidx.annotation.OptIn
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.media3.common.MediaItem
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.rtsp.RtspMediaSource
import com.sajat.ipkamera.databinding.ActivityMainBinding
import java.io.File
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding
    private var player: ExoPlayer? = null
    private val prefs by lazy { getSharedPreferences("kamera_prefs", Context.MODE_PRIVATE) }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        setupControls()
    }
    override fun onStart() { super.onStart(); startStream() }
    override fun onStop() { super.onStop(); releasePlayer() }
    private fun setupControls() {
        binding.switchRemote.isChecked = prefs.getBoolean("is_remote", false)
        binding.switchRemote.setOnCheckedChangeListener { _, isChecked ->
            prefs.edit().putBoolean("is_remote", isChecked).apply()
            startStream()
        }
        binding.btnSettings.setOnClickListener { showSettingsDialog() }
        binding.btnGallery.setOnClickListener { startActivity(Intent(this, GalleryActivity::class.java)) }
        binding.btnSnapshot.setOnClickListener { takeSnapshot() }
        binding.btnLeft.setOnClickListener { sendMove(-0.5f, 0f) }
        binding.btnRight.setOnClickListener { sendMove(0.5f, 0f) }
        binding.btnUp.setOnClickListener { sendMove(0f, 0.5f) }
        binding.btnDown.setOnClickListener { sendMove(0f, -0.5f) }
    }
    private fun sendMove(x: Float, y: Float) {
        val isRemote = prefs.getBoolean("is_remote", false)
        val onvifUrl = if (isRemote) prefs.getString("remote_onvif", "") ?: "" else prefs.getString("local_onvif", "http://192.168.1.100:80/onvif/ptz_service") ?: ""
        val token = prefs.getString("ptz_token", "Profile_1") ?: "Profile_1"
        OnvifPtzController.move(onvifUrl, token, x, y) { success ->
            runOnUiThread { if (!success) Toast.makeText(this, "PTZ hiba: ellenőrizd az ONVIF címet!", Toast.LENGTH_SHORT).show() }
        }
    }
    @OptIn(UnstableApi::class)
    private fun startStream() {
        releasePlayer()
        val isRemote = prefs.getBoolean("is_remote", false)
        val url = if (isRemote) prefs.getString("remote_rtsp", "") ?: "" else prefs.getString("local_rtsp", "rtsp://admin:12345@192.168.1.100:554/stream1") ?: ""
        if (url.isBlank()) { binding.tvStatus.text = "Nincs megadva kamera cím! Nyisd meg a Beállításokat."; return }
        binding.tvStatus.text = if (isRemote) "Csatlakozás (Távoli)..." else "Csatlakozás (Helyi)..."
        player = ExoPlayer.Builder(this).build().apply {
            binding.playerView.player = this
            val mediaSource = RtspMediaSource.Factory().setForceUseRtpTcp(true).createMediaSource(MediaItem.fromUri(url))
            setMediaSource(mediaSource)
            addListener(object : Player.Listener {
                override fun onPlaybackStateChanged(state: Int) {
                    if (state == Player.STATE_READY) binding.tvStatus.text = if (isRemote) "ÉLŐ (Távoli)" else "ÉLŐ (Helyi)"
                }
                override fun onPlayerError(error: PlaybackException) { binding.tvStatus.text = "Hiba: ${error.message}" }
            })
            prepare()
            playWhenReady = true
        }
    }
    private fun releasePlayer() { player?.release(); player = null }
    private fun takeSnapshot() {
        val videoSurface = binding.playerView.videoSurfaceView
        if (videoSurface is TextureView && videoSurface.isAvailable) {
            val bitmap: Bitmap? = videoSurface.bitmap
            if (bitmap != null) {
                val dir = File(filesDir, "snapshots").apply { mkdirs() }
                val timeStamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())
                val file = File(dir, "CAM_$timeStamp.jpg")
                FileOutputStream(file).use { out -> bitmap.compress(Bitmap.CompressFormat.JPEG, 90, out) }
                Toast.makeText(this, "Kép elmentve a memóriába!", Toast.LENGTH_SHORT).show()
                return
            }
        }
        Toast.makeText(this, "A kép mentéséhez indítsd el az élőképet!", Toast.LENGTH_SHORT).show()
    }
    private fun showSettingsDialog() {
        val layout = LinearLayout(this).apply { orientation = LinearLayout.VERTICAL; setPadding(40, 20, 40, 10) }
        val etLocalRtsp = EditText(this).apply { hint = "Helyi RTSP"; setText(prefs.getString("local_rtsp", "")) }
        val etRemoteRtsp = EditText(this).apply { hint = "Távoli RTSP"; setText(prefs.getString("remote_rtsp", "")) }
        val etLocalOnvif = EditText(this).apply { hint = "Helyi ONVIF PTZ URL"; setText(prefs.getString("local_onvif", "")) }
        val etRemoteOnvif = EditText(this).apply { hint = "Távoli ONVIF PTZ URL"; setText(prefs.getString("remote_onvif", "")) }
        val etToken = EditText(this).apply { hint = "ONVIF Token (Profile_1)"; setText(prefs.getString("ptz_token", "Profile_1")) }
        layout.addView(etLocalRtsp); layout.addView(etRemoteRtsp); layout.addView(etLocalOnvif); layout.addView(etRemoteOnvif); layout.addView(etToken)
        AlertDialog.Builder(this).setTitle("Beállítások").setView(layout).setPositiveButton("Mentés") { _, _ ->
            prefs.edit().putString("local_rtsp", etLocalRtsp.text.toString().trim()).putString("remote_rtsp", etRemoteRtsp.text.toString().trim()).putString("local_onvif", etLocalOnvif.text.toString().trim()).putString("remote_onvif", etRemoteOnvif.text.toString().trim()).putString("ptz_token", etToken.text.toString().trim()).apply()
            startStream()
        }.setNegativeButton("Mégse", null).show()
    }
}
