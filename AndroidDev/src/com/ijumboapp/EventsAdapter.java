package com.ijumboapp;

import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;


public class EventsAdapter extends ArrayAdapter<Object> {

	private Object[] data;
	private Context context;
	
	public EventsAdapter(Context context, int textViewResourceId, Object[] objects) {
		super(context, textViewResourceId);
		this.data = objects;
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
		 holder.tView.setText(this.data[position].toString());
		 return cell;
	 }
	 
	@Override
	public int getCount() {
		return this.data.length;
	}	
	
	static class Holder {
		TextView tView;
	}
}

