package com.ijumboapp;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;


public class MenuAdapter extends ArrayAdapter<JSONObject> {

	Context context;
	int resourceID;
	JSONObject data[];
	Set<Integer> sectionLocations;
	String diningHall;
	
	public MenuAdapter(Context context, int textViewResourceId, JSONObject[] objects, String diningHall) {
		super(context, textViewResourceId, objects);
		this.context = context;
		this.resourceID = textViewResourceId;
		this.sectionLocations = new HashSet<Integer>();
		this.diningHall = diningHall;
		try {
			this.parseData(objects);
		} catch (JSONException e) {
			System.out.println("MenuAdapter.parseData Error: " + e);
		}
		System.out.println("DATA COUNT FOR ADAPTER: " + this.getCount());
	}
	
	private void parseData(JSONObject[] objects) throws JSONException {
		List<JSONObject> foodWithSections = new ArrayList<JSONObject>();
		// add the dining hall info to the top of the listView
		JSONObject hallCell   = new JSONObject();
		hallCell.put("FoodName", this.diningHall + " Info");
		JSONObject hallHeader = new JSONObject();
		hallHeader.put("SectionName", "Dining Hall Info");
		foodWithSections.add(hallHeader);
		foodWithSections.add(hallCell);
		this.sectionLocations.add(Integer.valueOf(0));
		// add all of the food as well
		for(JSONObject section : objects) {
			JSONObject sectionData = new JSONObject();
			sectionData.put("SectionName", section.get("SectionName"));
			foodWithSections.add(sectionData);
			this.sectionLocations.add(foodWithSections.size() - 1);
			JSONArray sectionFood = section.getJSONArray("foods"); 
			int foodLength = sectionFood.length();
			// grab the array and add the entire thing
			for(int i = 0; i < foodLength; i++) {
				foodWithSections.add(sectionFood.getJSONObject(i));
			}
		}
		this.data = new JSONObject[foodWithSections.size()];
		for(int i = 0; i < foodWithSections.size(); i++) {
			this.data[i] = foodWithSections.get(i);
		}
	}

	 @Override
	 public View getView(int position, View convertView, ViewGroup parent) {
		 View cell = convertView;
		 LayoutInflater inflater = ((Activity)context).getLayoutInflater();
		 JSONObject cellData = this.data[position];
		 boolean isHeader = this.sectionLocations.contains(Integer.valueOf(position));
		 if(isHeader) {
			 cell = inflater.inflate(R.layout.listview_header_row, parent, false);
	   		 cell.setOnClickListener(null);
	   		 try {
				((TextView)cell.findViewById(R.id.txtHeader)).setText(cellData.getString("SectionName"));
			} catch (JSONException e) {}
		 } else {
			 cell = inflater.inflate(R.layout.listview_item_row, parent, false);
			 cell.setOnClickListener(this.itemListener(position));
			 try {
				((TextView)cell.findViewById(R.id.txtTitle)).setText(cellData.getString("FoodName"));
			} catch (JSONException e) {}
		 }
		 
		return cell;
	 }
	 
	 private OnClickListener itemListener(final int position) {
		 // if the position is the dining hall info cell
		 if(position == 1) {
			 // TODO -- return a listener to push an activity showing info on a place
			 return null;
		 }
		 return new OnClickListener() {
        	 @Override
        	 public void onClick(View v) {
        		Intent intent = null;
	  		 	intent = new Intent(context, FoodView.class);
	  		 	intent.putExtra("data", MenuAdapter.this.data[position].toString());
	  		 	context.startActivity(intent);
        	 }
		 };
	 }
	 
	@Override
	public int getCount() {
		return this.data.length;
	}	
}


