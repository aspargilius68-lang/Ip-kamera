#!/bin/bash
set -e
echo "=== Saját IP Kamera Android Projekt Generálása ==="
mkdir -p SajatIPKamera/.github/workflows
mkdir -p SajatIPKamera/app/src/main/java/com/sajat/ipkamera
mkdir -p SajatIPKamera/app/src/main/res/layout

cat << 'EOF' > SajatIPKamera/settings.gradle.kts
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "SajatIPKamera"
include(":app")
EOF

cat << 'EOF' > SajatIPKamera/build.gradle.kts
plugins {
    id("com.android.application") version "8.5.2" apply false
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
}
EOF

cat << 'EOF' > SajatIPKamera/gradle.properties
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
kotlin.code.style=official
android.nonTransitiveRClass=true
EOF

cat << 'EOF' > SajatIPKamera/app/build.gradle.kts
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}
android {
    namespace = "com.sajat.ipkamera"
    compileSdk = 34
    defaultConfig {
        applicationId = "com.sajat.ipkamera"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }
    buildFeatures {
        viewBinding = true
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
}
dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    val media3Version = "1.4.1"
    implementation("androidx.media3:media3-exoplayer:$media3Version")
    implementation("androidx.media3:media3-exoplayer-rtsp:$media3Version")
    implementation("androidx.media3:media3-ui:$media3Version")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
}
EOF

cat << 'EOF' > SajatIPKamera/app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <application
        android:allowBackup="true"
        android:label="Saját IP Kamera"
        android:supportsRtl="true"
        android:theme="@style/Theme.Material3.Dark.NoActionBar"
        android:usesCleartextTraffic="true">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:screenOrientation="unspecified">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        <activity
            android:name=".GalleryActivity"
            android:exported="false" />
    </application>
</manifest>
EOF

cat << 'EOF' > SajatIPKamera/app/src/main/res/layout/activity_main.xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="#121212">
    <androidx.media3.ui.PlayerView
        android:id="@+id/playerView"
        android:layout_width="0dp"
        android:layout_height="0dp"
        app:layout_constraintBottom_toTopOf="@+id/controlPanel"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent"
        app:use_controller="false" />
    <TextView
        android:id="@+id/tvStatus"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:background="#99000000"
        android:padding="8dp"
        android:text="Csatlakozás..."
        android:textColor="#FFFFFF"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />
    <LinearLayout
        android:id="@+id/controlPanel"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:background="#1E1E1E"
        android:gravity="center"
        android:orientation="vertical"
        android:padding="12dp"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent">
        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:gravity="center"
            android:orientation="horizontal">
            <com.google.android.material.switchmaterial.SwitchMaterial
                android:id="@+id/switchRemote"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="Távoli mód "
                android:textColor="#FFFFFF" />
            <Button
                android:id="@+id/btnSettings"
                style="@style/Widget.Material3.Button.TonalButton"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginStart="12dp"
                android:text="Beállítások" />
            <Button
                android:id="@+id/btnGallery"
                style="@style/Widget.Material3.Button.TonalButton"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginStart="8dp"
                android:text="Memória" />
        </LinearLayout>
        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_marginTop="8dp"
            android:gravity="center"
            android:orientation="horizontal">
            <Button
                android:id="@+id/btnLeft"
                android:layout_width="60dp"
                android:layout_height="wrap_content"
                android:text="◀" />
            <LinearLayout
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginHorizontal="6dp"
                android:orientation="vertical">
                <Button
                    android:id="@+id/btnUp"
                    android:layout_width="60dp"
                    android:layout_height="wrap_content"
                    android:text="▲" />
                <Button
                    android:id="@+id/btnDown"
                    android:layout_width="60dp"
                    android:layout_height="wrap_content"
                    android:text="▼" />
            </LinearLayout>
            <Button
                android:id="@+id/btnRight"
                android:layout_width="60dp"
                android:layout_height="wrap_content"
                android:text="▶" />
            <Button
                android:id="@+id/btnSnapshot"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:layout_marginStart="16dp"
                android:backgroundTint="#2E7D32"
                android:text="📷 Fotó" />
        </LinearLayout>
    </LinearLayout>
</androidx.constraintlayout.widget.ConstraintLayout>
EOF

cat << 'EOF' > SajatIPKamera/app/src/main/java/com/sajat/ipkamera/OnvifPtzController.kt
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
EOF

cat << 'EOF' > SajatIPKamera/app/src/main/java/com/sajat/ipkamera/MainActivity.kt
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
EOF

cat << 'EOF' > SajatIPKamera/app/src/main/java/com/sajat/ipkamera/GalleryActivity.kt
package com.sajat.ipkamera
import android.graphics.BitmapFactory
import android.os.Bundle
import android.widget.ArrayAdapter
import android.widget.Button
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.ListView
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import java.io.File
class GalleryActivity : AppCompatActivity() {
    private lateinit var tvStorageInfo: TextView
    private lateinit var listView: ListView
    private var files: List<File> = emptyList()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val root = LinearLayout(this).apply { orientation = LinearLayout.VERTICAL; setPadding(24, 24, 24, 24) }
        tvStorageInfo = TextView(this).apply { textSize = 16f; setPadding(0, 0, 0, 16) }
        val btnClearAll = Button(this).apply { text = "Összes kép törlése (Memória ürítése)"; setOnClickListener { files.forEach { it.delete() }; loadFiles() } }
        listView = ListView(this).apply { setOnItemClickListener { _, _, position, _ -> showImageDialog(files[position]) } }
        root.addView(tvStorageInfo); root.addView(btnClearAll); root.addView(listView)
        setContentView(root)
        loadFiles()
    }
    private fun loadFiles() {
        val dir = File(filesDir, "snapshots")
        files = dir.listFiles()?.sortedByDescending { it.lastModified() } ?: emptyList()
        val totalKb = files.sumOf { it.length() } / 1024
        tvStorageInfo.text = "Mentett képek: ${files.size} db | Foglalt hely: $totalKb KB"
        listView.adapter = ArrayAdapter(this, android.R.layout.simple_list_item_1, files.map { "${it.name} (${it.length() / 1024} KB)" })
    }
    private fun showImageDialog(file: File) {
        val imageView = ImageView(this).apply { setImageBitmap(BitmapFactory.decodeFile(file.absolutePath)); adjustViewBounds = true }
        AlertDialog.Builder(this).setTitle(file.name).setView(imageView).setPositiveButton("Bezárás", null).setNegativeButton("Törlés") { _, _ -> file.delete(); loadFiles() }.show()
    }
}
EOF

cat << 'EOF' > SajatIPKamera/.github/workflows/build.yml
name: APK Fordítás
on: [push, workflow_dispatch]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
      - name: Setup Gradle
        uses: gradle/actions/setup-gradle@v4
        with:
          gradle-version: '8.7'
      - name: Build Debug APK
        run: gradle assembleDebug
      - name: APK Feltöltése Letöltéshez
        uses: actions/upload-artifact@v4
        with:
          name: Sajat-IP-Kamera-APK
          path: app/build/outputs/apk/debug/app-debug.apk
EOF

echo "KÉSZ! A teljes SajatIPKamera projekt létrejött."
