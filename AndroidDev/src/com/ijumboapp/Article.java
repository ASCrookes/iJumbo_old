package com.ijumboapp;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.Serializable;
import java.net.HttpURLConnection;
import java.net.URL;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;


public class Article implements Serializable {
	
	private static final long serialVersionUID = 1L;
	
	protected String title;
	protected String link;
	protected String author;
	//private ImageData 
	protected String imageURL;
	protected byte[] imageBytes;

	
	public Article() {
		this.title = "N/A";
		this.link = "N/A";
		this.author = "N/A";
		this.imageURL = "N/A";
		this.imageBytes = null;
	}
	
	// the adapter has a list of Article objects so this is what prints to the lsit
	public String toString() {
		return this.title + "\nAuthor: " + this.author;
	}
	
	public boolean equals(Article article) {
		return     this.title.equals(article.title) 
				&& this.author.equals(article.author);
	}
	
	public boolean isValidArticle() {
		return     !this.title.equals("N/A")
				&& !this.link.equals("N/A")
				&& !this.author.equals("N/A");
	}
	
	public void addFieldFromRss(String rssTag, String value) {
		if(rssTag.equals("title")) {
			this.title = value;
		}
		else if(rssTag.equals("author") || rssTag.equals("dc:creator"))
			this.author = value;
		else if(rssTag.equals("link"))
			this.link = value;
		else if(rssTag.equals("thumbnail")) {
			// strip url of whitespace
			this.imageURL = value.replaceAll("\\s*", "");
		}
	}
	
	public void downloadImage() {
		if(this.imageURL.equals("") || this.imageBytes != null) {
			return;
		}
		// Something about getting the image adds articles mutliple times
		// and rearranges them.
		
		try {
			URL url = new URL(this.imageURL);
			HttpURLConnection connection = (HttpURLConnection) url.openConnection();
			connection.setChunkedStreamingMode(10000); // TODO -- is this necessary
			InputStream is = connection.getInputStream();
			Bitmap bitmap = BitmapFactory.decodeStream(is);
			ByteArrayOutputStream stream = new ByteArrayOutputStream();
			bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
			this.imageBytes = stream.toByteArray();			
		} catch (IOException e) {
			this.imageBytes = null;
		}
	}
	
	public Bitmap getImageBitmap() {
		if(this.imageBytes == null) {
			return null;
		}
		return BitmapFactory.decodeByteArray(this.imageBytes, 0, this.imageBytes.length);
	}
}
