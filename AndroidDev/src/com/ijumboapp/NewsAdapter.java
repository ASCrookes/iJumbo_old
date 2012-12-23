package com.ijumboapp;

import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
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
		 View cell = convertView;
		 // use a holder so that findViewById does not need to be called everytime
		 Holder holder = null;
		 if(cell == null) {
			 	LayoutInflater inflater = ((Activity)context).getLayoutInflater();
	            cell = inflater.inflate(R.layout.news_listview_row, parent, false);
	            holder = new Holder();
	            holder.textV = (TextView) cell.findViewById(R.id.txtTitleNews);
	            holder.imageV = (ImageView) cell.findViewById(R.id.imgIconNews);
	            cell.setTag(holder);
		 } else {
			 holder = (Holder) cell.getTag();
		 }
		 
		 holder.textV.setText(data[position].toString());
		 Bitmap bitmap = data[position].getImageBitmap();
		 if(bitmap == null) {
			 bitmap = BitmapFactory.decodeResource(context.getResources(), R.drawable.news_default_white);
		 }
		 
		 holder.imageV.setImageBitmap(bitmap);
		 
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
}
