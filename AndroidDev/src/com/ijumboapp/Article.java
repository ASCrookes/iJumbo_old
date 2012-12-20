package com.ijumboapp;

import java.io.InputStream;
import java.io.Serializable;
import java.net.HttpURLConnection;
import java.net.URL;

import android.graphics.Bitmap;

public class Article implements Serializable {
	
	private static final long serialVersionUID = 1L;
	
	protected String title;
	protected String link;
	protected String author;
	//private ImageData 
	protected String imageURL;
	protected Bitmap imageBitmap;

	
	public Article() {
		this.title = "N/A";
		this.link = "N/A";
		this.author = "N/A";
		this.imageURL = "N/A";
		this.imageBitmap = null;
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
			if(this.imageURL.equals("") || this.imageBitmap != null) {
				return;
			}
			// Something about getting the image adds articles mutliple times
			// and rearranges them.
			URL url = null;
			HttpURLConnection connection = null;
			InputStream is = null;
			/*
			try {
				
				url = new URL(this.imageURL);
				connection = (HttpURLConnection) url.openConnection();
				connection.setChunkedStreamingMode(10000);
				is = connection.getInputStream();
				this.imageBitmap = BitmapFactory.decodeStream(is);
				
				
				URLConnection connection = new URI(this.imageURL).toURL().openConnection();
				connection.connect();
				InputStream is = connection.getInputStream();
				BufferedInputStream bis = new BufferedInputStream(is, 8 * 1024);
				this.imageBitmap = BitmapFactory.decodeStream(bis);
				bis.close();
				is.close(); 
				
			} catch (IOException e) {
				this.imageBitmap = null;
				e.printStackTrace();
				System.out.println("Artilce thumbnail EXCEPTION: " + e);
			} catch (URISyntaxException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			*/
		}
	}
}
