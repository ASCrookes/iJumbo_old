package com.ijumboapp;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;


public class EventsAdapter extends ArrayAdapter<Object> {

	private JSONArray events;
	private Context context;
	
	public EventsAdapter(Context context, int textViewResourceId, JSONArray objects) {
		super(context, textViewResourceId);
		this.events = objects;
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
		 JSONObject event;
		try {
			event = (JSONObject) this.events.getJSONObject(position).getJSONObject("event");
			holder.tView.setText(event.getString("title"));
		} catch (JSONException e) {
			holder.tView.setText("Title is unavailable");
		}
		return cell;
	 }
	 
	@Override
	public int getCount() {
		if (this.events == null)
			return 0;
		return this.events.length();
	}	
	
	static class Holder {
		TextView tView;
	}
}

