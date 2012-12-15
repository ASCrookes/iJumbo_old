package com.ijumboapp;

import java.io.InputStream;
import java.net.URL;

import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

public class NewsAdapter extends ArrayAdapter<JSONObject> {

	Context context;
	int resourceID;
	Article[] data;
	
	public NewsAdapter(Context context, int textViewResourceId, Article[] objects) {
		super(context, textViewResourceId);
		this.data = objects;
		this.context = context;
		this.resourceID = textViewResourceId;
	}


	 @Override
	 public View getView(int position, View convertView, ViewGroup parent) {
		 System.out.println("GETTING VIEW FROM NEWS ADAPTER");
		 View cell = convertView;
		 Holder holder = null;
		 if(cell == null) {
			 	LayoutInflater inflater = ((Activity)context).getLayoutInflater();
	            cell = inflater.inflate(this.resourceID, parent, false);
	            
	            holder = new Holder();
	            holder.textV = (TextView) cell.findViewById(R.id.txtTitleNews);
	            holder.imageV = (ImageView) cell.findViewById(R.id.imgIconNews);
	            
	            cell.setTag(holder);
		 } else {
			 holder = (Holder) cell.getTag();
		 }
		 holder.textV.setText(data[position].toString());
		 String imageUrl = data[position].imageURL.replaceAll("\\s*", "");
		 //System.out.println("IMAGE URL IN NEWS ADAPTER: " + imageUrl);
		 if(!imageUrl.equals("")) {
			 System.out.println(imageUrl);
			 System.out.println(getUrlDrawable(imageUrl));
			 holder.imageV.setImageDrawable(getUrlDrawable(imageUrl));
		 } else {
			 holder.imageV.setImageDrawable(null);
		 }
		 
		 
		return cell;
	 }
	
	 
	 
	static class Holder {
		TextView textV;
		ImageView imageV;
	}
	
	@Override
	public int getCount() {
		return this.data.length;
	}	
	
	private Drawable getUrlDrawable(String url) {
		try
		{
			InputStream is = (InputStream) new URL(url).getContent();
			Drawable d = Drawable.createFromStream(is, "src name");
			return d;
	  	} catch (Exception e) {
		  	System.out.println("Exc="+e);
	   		return null;
	  	}
	}
}
