package com.ijumboapp;

import java.io.Serializable;

import android.text.Html;

public class Event extends Object implements Serializable {
	
	private static final long serialVersionUID = 1L;
	protected String title;
	protected String startTime;
	protected String endTime;
	protected String description;
	protected String location;
	protected String date;
	protected String link;
	
	public Event() {
		this.title       = "N/A";
		this.startTime   = "N/A";
		this.endTime     = "N/A";
		this.description = "N/A";
		this.location    = "N/A";
		this.link        = "N/A";
		this.date        = "N/A";
	}
	
	// set the values to those given
	// if an argument is null make the string "N/A"
	public Event(String title, String start, String end, String desc, String loc) {
		this.title = (title == null) ? "N/A" : title;
		this.startTime = (start == null) ? "N/A" : this.get12HourTime(start);
		this.endTime = (end == null) ? "N/A" : this.get12HourTime(end);
		this.description = (desc == null) ? "N/A" : desc;
		this.location = (loc == null) ? "N/A" : loc;
	}
	
	// converts time from 24 to 12 hours
	private String get12HourTime(String time) {
		int hours = Integer.valueOf(time.substring(0, 2));
		String ending = "AM";
		if(hours > 12) {
			hours = hours % 12;
			ending = "PM";
		} else if(hours == 12) {
			return "NOON";
		} else if(hours == 0) {
			return "MIDNIGHT";
		}
		String hourStr = (hours < 10) ? "0" : "";
		return hourStr + hours + time.substring(2, 5) + ending;
	}
	
	public String toString() {
		return this.title + "\n  " + this.startTime + "-" + this.endTime;
	}	
	
	public void addFieldFromRss(String rssTag, String value) {

		if(rssTag.equals("title"))
			this.title = value;
		else if(rssTag.equals("event_start"))
			this.startTime = this.get12HourTime(value);
		else if(rssTag.equals("event_end"))
			this.endTime = this.get12HourTime(value);
		else if(rssTag.equals("description"))
			this.description = Html.fromHtml(value).toString();
		else if(rssTag.equals("location"))
			this.location = value;
		else if(rssTag.equals("link"))
			this.link = value;
		else if(rssTag.equals("event_date"))
			this.date = value;
	}

}
