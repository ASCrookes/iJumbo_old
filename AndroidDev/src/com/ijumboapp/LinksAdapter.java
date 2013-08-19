package com.ijumboapp;

import org.json.JSONArray;
import org.json.JSONException;
import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

public class LinksAdapter extends ArrayAdapter<Object> {

	private JSONArray links;
	private Context context;
	
	public LinksAdapter(Context context, int textViewResourceId, JSONArray objects) {
		super(context, textViewResourceId);
		this.links = objects;
		this.context = context;
	}

	@Override
	 public View getView(int position, View convertView, ViewGroup parent) {
		 View cell = convertView;
		 LayoutInflater inflater = ((Activity)context).getLayoutInflater();
		 Holder holder = null;
		 if(cell == null) {
			 cell = inflater.inflate(R.layout.listview_item_row, parent, false);
			 holder = new Holder();
			 holder.tView = (TextView) cell.findViewById(R.id.txtTitle);
			 cell.setTag(holder);
		 } else {
			 holder = (Holder) cell.getTag();
		 }
		 try {
			holder.tView.setText(links.getJSONObject(position).getString("name"));
		} catch (JSONException e) {
			holder.tView.setText("Name not available");
		}
		 
		return cell;
	 }
	 
	@Override
	public int getCount() {
		return this.links.length();
	}	
	
	static class Holder {
		TextView tView;
	}
	
}
