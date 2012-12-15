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
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import com.ijumboapp.MenuAdapter.FoodHolder;

public class PlacesAdapter  extends ArrayAdapter<JSONObject> {

	Context context;
	int resourceID;
	JSONObject data[];
	Set<Integer> sectionLocations;
	
	public PlacesAdapter(Context context, int textViewResourceId, JSONArray objects) {
		super(context, textViewResourceId);
		this.context = context;
		this.resourceID = textViewResourceId;
		this.sectionLocations = new HashSet<Integer>();
		try {
			this.parseData(objects);
		} catch (JSONException e) {
			System.out.println("MenuAdapter.parseData Error: " + e);
		}
		System.out.println("DATA COUNT FOR ADAPTER: " + this.getCount());
	}
	
	private void parseData(JSONArray sections) throws JSONException {
		List<JSONObject> placesWithSections = new ArrayList<JSONObject>();
		for(int i = 0; i < sections.length(); i++) {
			JSONArray section = sections.getJSONArray(i);
			JSONObject sectionHeader = new JSONObject();
			sectionHeader.put("sectionName", getSectionTitle(section));
			// add the header right here
			placesWithSections.add(sectionHeader);
			this.sectionLocations.add(placesWithSections.size() - 1);
			for(int j = 0; j < section.length(); j++) {
				placesWithSections.add(section.getJSONObject(j));
			}
		}
		System.out.println("THE SET: " + this.sectionLocations);
		this.data = new JSONObject[placesWithSections.size()];
		for(int i = 0; i < placesWithSections.size(); i++) {
			this.data[i] = placesWithSections.get(i);
		}
	}
	
	static private String getSectionTitle(JSONArray section) {
		String sectionTitle = "";
		try {
			sectionTitle = section.getJSONObject(0).getString("building_name");
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		sectionTitle = sectionTitle.substring(0, 1);
		if(sectionTitle.equals("1")) {
			sectionTitle = "123";
		}
		return sectionTitle;
	}

	 @Override
	 public View getView(int position, View convertView, ViewGroup parent) {
		 View cell = convertView;
		 PlaceDataHolder holder = null;
		 final boolean isHeader = this.sectionLocations.contains(Integer.valueOf(position));
		 if(cell == null) {
			 	LayoutInflater inflater = ((Activity)context).getLayoutInflater();
			 	if(isHeader) {
			 		// TODO -- give a specific id for a section header cell
			 		// create a section header in xml
			 	} else {
			 		// give the cell the normal id for a cell
			 	}
			 	
	            cell = inflater.inflate(this.resourceID, parent, false);
	            
	            holder = new PlaceDataHolder();
	            holder.placeData = this.data[position];
	            holder.textV = (TextView) cell.findViewById(R.id.txtTitle);
	            //System.out.println("THE TEXT VIEW: " + holder.textV);
	            holder.index = (isHeader) ? -1 : position;
	            cell.setTag(holder);
	            final Context context = getContext();
	   		 	cell.setOnClickListener(new OnClickListener() {
	   		 		@Override
	   		 		public void onClick(View v) {
	   		 			// TODO -- add functionality to go to a view specific to the building selected
	   		 		}
	   		 	});  
		 } else {
			 holder = (PlaceDataHolder)cell.getTag();
		 }
		 // because the dining hall info this has to be offset
		 // TODO -- change the adapters so that this only happens when the cell is created to avoid moving data a lot
		 JSONObject cellData = this.data[position];
		 try {
			 if(isHeader) {
				 holder.textV.setText(cellData.getString("sectionName"));
				 holder.textV.setBackgroundColor(Color.GRAY);
				 
			 } else {
				 holder.textV.setText(cellData.getString("building_name"));
				 holder.textV.setBackgroundColor(Color.TRANSPARENT);
			 }
		 } catch (JSONException e) {
			 holder.textV.setText("THERE WAS AN ERROR IN PLACEADAPTER");
			 System.out.println("PlaceAdapter.getView Error: " + e);
			 System.out.println("THE DATA USED: " + holder.placeData);
		}
		 
		return cell;
	 }
	
	 
	 
	static class PlaceDataHolder {
		TextView textV;
		JSONObject placeData;
		int index;
	}
	
	@Override
	public int getCount() {
		return this.data.length;
	}	
}


