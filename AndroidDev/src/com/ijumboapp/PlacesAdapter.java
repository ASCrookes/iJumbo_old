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
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.AdapterView.OnItemClickListener;

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
		final PlacesActivity activity = (PlacesActivity) context;
		ListView lView = (ListView) activity.findViewById(R.id.placesList);
		lView.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
				// do nothing if a section was selected
				if(PlacesAdapter.this.sectionLocations.contains(arg2)) {
					return;
				}
				System.out.println("CLOCKED THAT BITCH!");
				Intent intent = new Intent(activity, PlaceView.class);
				intent.putExtra("place", PlacesAdapter.this.data[arg2].toString());
				System.out.println("THE PLACE IN THE INTENT: " + intent.getStringExtra("place"));
				activity.startActivity(intent);
			}
		});
	}
	
	private void parseData(JSONArray sections) throws JSONException {
		List<JSONObject> placesWithSections = new ArrayList<JSONObject>();
		for(int i = 0; i < sections.length(); i++) {
			JSONArray section = sections.getJSONArray(i);
			JSONObject sectionHeader = new JSONObject();
			sectionHeader.put("SectionName", getSectionTitle(section));
			// add the header right here
			placesWithSections.add(sectionHeader);
			this.sectionLocations.add(placesWithSections.size() - 1);
			for(int j = 0; j < section.length(); j++) {
				placesWithSections.add(section.getJSONObject(j));
			}
		}
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
		 LayoutInflater inflater = ((Activity)context).getLayoutInflater();
		 final boolean isHeader = this.sectionLocations.contains(Integer.valueOf(position));
		 JSONObject cellData = this.data[position];
		 if(isHeader) {
			 cell = inflater.inflate(R.layout.listview_header_row, parent, false);
			 try {
				((TextView)cell.findViewById(R.id.txtHeader)).setText(cellData.getString("SectionName"));
			} catch (JSONException e) {}
		 } else {
			 cell = inflater.inflate(R.layout.listview_item_row, parent, false);
			 try {
				((TextView)cell.findViewById(R.id.txtTitle)).setText(cellData.getString("building_name"));
			} catch (JSONException e) {}
		 }

		return cell;
	}
	

	
	@Override
	public int getCount() {
		return this.data.length;
	}	
}


