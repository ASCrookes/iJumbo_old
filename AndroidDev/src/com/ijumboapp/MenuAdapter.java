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
		hallHeader.put("sectionName", "Dining Hall Info");
		foodWithSections.add(hallHeader);
		foodWithSections.add(hallCell);
		this.sectionLocations.add(Integer.valueOf(0));
		// add all of the food as well
		for(JSONObject section : objects) {
			JSONObject sectionData = new JSONObject();
			sectionData.put("sectionName", section.get("SectionName"));
			foodWithSections.add(sectionData);
			this.sectionLocations.add(foodWithSections.size() - 1);
			System.out.println("Added location to set: " + (foodWithSections.size() - 1));
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
		 FoodHolder holder = null;
		 boolean isHeader = this.sectionLocations.contains(Integer.valueOf(position));
		 if(cell == null) {
			 	LayoutInflater inflater = ((Activity)context).getLayoutInflater();
	            cell = inflater.inflate(this.resourceID, parent, false);
	            
	            holder = new FoodHolder();
	            holder.foodData = this.data[position];
	            holder.textV = (TextView)cell.findViewById(R.id.txtTitle);
	            holder.index = (isHeader) ? -1 : position;
	            cell.setTag(holder);
	            final Context context = getContext();
	   		 cell.setOnClickListener(new OnClickListener() {
	        	 @Override
	        	 public void onClick(View v) {
	        		FoodHolder holder = (FoodHolder) v.getTag();
	        		Intent intent = null;
		  		 	if(holder.index > 1) {
		  		 		intent = new Intent(context, FoodActivity.class);
		  		 		intent.putExtra("data", holder.foodData.toString());
		  		 		context.startActivity(intent);
		  		 	} else if(holder.index == 1) {
		  		 		//intent = new Intent(context, SOMEWHERE ELSE);
		  		 	}
	        	 }
			});
		        
		 } else {
			 holder = (FoodHolder)cell.getTag();
		 }
		 // because the dining hall info this has to be offset

		 JSONObject cellData = this.data[position];
		 try {
			 if(isHeader) {
				 holder.textV.setText(cellData.getString("sectionName"));
				 holder.textV.setBackgroundColor(Color.GRAY);
				 holder.index = -1;
			 } else {
				 holder.textV.setText(cellData.getString("FoodName"));
				 holder.textV.setBackgroundColor(Color.TRANSPARENT);
				 holder.index = position;
				 holder.foodData = data[position];
			 }
		 } catch (JSONException e) {
			 holder.textV.setText("THERE WAS AN ERROR IN MENUADAPTER");
			 System.out.println("MenuAdapter.getView Error: " + e);
		}
		 
		return cell;
	 }
	
	 
	 
	static class FoodHolder {
		TextView textV;
		JSONObject foodData;
		int index;
	}
	
	@Override
	public int getCount() {
		return this.data.length;
	}	
}


