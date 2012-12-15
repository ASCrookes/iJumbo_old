package com.ijumboapp;

public class Article {
	
	protected String title;
	protected String link;
	protected String author;
	//private ImageData 
	protected String imageURL;

	
	public Article() {
		this.title = "N/A";
		this.link = "N/A";
		this.author = "N/A";
		this.imageURL = "N/A";
	}
	
	// the adapter has a list of Article objects so this is what prints to the lsit
	public String toString() {
		return this.title + "\nAuthor: " + this.author;
	}
	
	public void addFieldFromRss(String rssTag, String value) {
		if(rssTag.equals("title"))
			this.title = value;
		else if(rssTag.equals("author") || rssTag.equals("dc:creator"))
			this.author = value;
		else if(rssTag.equals("link"))
			this.link = value;
		else if(rssTag.equals("media:thumbnail")) {
			this.imageURL = value;
			//String data = new RequestManager().get(this.imageURL);
			//System.out.println(data);
		}
	}
}

