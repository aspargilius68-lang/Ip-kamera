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
