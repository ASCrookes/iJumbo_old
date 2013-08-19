package com.ijumboapp;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.ijumboapp.EventsAdapter.Holder;

import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

public class JoeyAdapter extends ArrayAdapter<Object> {

	Context context;
	String[] etas;

	public JoeyAdapter(Context context, int textViewResourceId, String[] objects) {
		super(context, textViewResourceId);
		this.etas = objects;
		this.context = context;
	}

	@Override
	 public View getView(int position, View convertView, ViewGroup parent) {
		 View cell = convertView;
		 LayoutInflater inflater = ((Activity)context).getLayoutInflater();
		 Holder holder = null;
		 if(cell == null) {
			 cell = inflater.inflate(R.layout.events_item_row, parent, false);
			 holder = new Holder();
			 holder.tView = (TextView) cell.findViewById(R.id.txtTitleEvents);
			 cell.setTag(holder);
		 } else {
			 holder = (Holder) cell.getTag();
		 }
		 if (position == 0) {
			 holder.tView.setText("Joey Schedule");
		 } else {
			 holder.tView.setText(etas[position]);
		 }
		return cell;
	 }
	 
	@Override
	public int getCount() {
		return this.etas.length + 1;
	}	
	
	static class Holder {
		TextView tView;
	}
}
