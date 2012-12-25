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
import android.net.Uri;
import android.sax.StartElementListener;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;


public class PlacesAdapter  extends ArrayAdapter<JSONObject> {

	final int HEADER_ITEM_VIEW_TYPE = 0;
	final int ROW_ITEM_VIEW_TYPE = 1;
	
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
		} catch (JSONException e) {}
		final PlacesActivity activity = (PlacesActivity) context;
		ListView lView = (ListView) activity.findViewById(R.id.placesList);
		lView.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
				// do nothing if a section was selected
				if(PlacesAdapter.this.sectionLocations.contains(arg2)) {
					return;
				}
				Intent intent = new Intent(activity, PlaceView.class);
				intent.putExtra("place", PlacesAdapter.this.data[arg2].toString());
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
		// if it is the header just create a new view and return it
		if(isHeader) {
			View cellHeader = inflater.inflate(R.layout.listview_header_row, parent, false);
			try {
				((TextView)cellHeader.findViewById(R.id.txtHeader)).setText(cellData.getString("SectionName"));
			} catch (JSONException e) {}
			return cellHeader;
		}
		Holder holder;
		if(cell == null || cell.getId() == R.layout.listview_header_row) {
			cell = inflater.inflate(R.layout.places_listview_row, parent, false);
			holder = new Holder();
			holder.tView = (TextView) cell.findViewById(R.id.txtTitle_place);
			holder.infoButton = cell.findViewById(R.id.placesRowInfoButton);
			holder.mapButton  = cell.findViewById(R.id.placesRowMapButton);
			holder.infoButton.setOnClickListener(this.infoOnClickListener());
			holder.mapButton.setOnClickListener(this.mapOnClickListener());
			cell.setOnClickListener(this.cellOnClickListener());
			cell.setTag(holder);
		} else {
			holder = (Holder) cell.getTag();
		}
		
		try {
			holder.tView.setText(cellData.getString("building_name"));
		} catch (JSONException e) {}
		holder.infoButton.setTag(position);
		holder.mapButton.setTag(position);
		holder.position = position;
		 
		return cell;
	}
	
	private OnClickListener infoOnClickListener() {
		return new OnClickListener() {
			@Override
			public void onClick(View v) {
				int position = (Integer) v.getTag();
				Activity activity = (Activity)PlacesAdapter.this.context;
				Intent intent = new Intent(activity, PlaceView.class);
				intent.putExtra("place", PlacesAdapter.this.data[position].toString());
				activity.startActivity(intent);
			}
		};
	}
	
	private OnClickListener mapOnClickListener() {
		return new OnClickListener() {
			@Override
			public void onClick(View v) {
				int position = (Integer) v.getTag();
				JSONObject place = PlacesAdapter.this.data[position];
				String mapQuery = null;
				try {
					mapQuery = String.format("http://maps.google.com/maps?q=%s,+%s+(%s)", place.getString("latitude"), place.getString("longitude"), place.getString("building_name"));
				} catch(JSONException e) {
					mapQuery = null;
				}
				if(mapQuery != null) {
					Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(mapQuery));
					Activity activity = (Activity) PlacesAdapter.this.context;
					activity.startActivity(intent);
				}
			}
		};
	}
	
	private OnClickListener cellOnClickListener() {
		return new OnClickListener() {
			@Override
			public void onClick(View v) {
				Holder holder = (Holder) v.getTag();
				Activity activity = (Activity)PlacesAdapter.this.context;
				Intent intent = new Intent(activity, PlaceView.class);
				intent.putExtra("place", PlacesAdapter.this.data[holder.position].toString());
				activity.startActivity(intent);
			}
		};
	}

	
	@Override
	public int getCount() {
		return this.data.length;
	}	
	
	@Override 
	public int getViewTypeCount() {
		return 2;
	}
	
	@Override
	public int getItemViewType(int position) {
		if(this.sectionLocations.contains(position)) {
			return HEADER_ITEM_VIEW_TYPE;
		}
		return ROW_ITEM_VIEW_TYPE;
	}
	
	private class Holder {
		TextView tView;
		View mapButton;
		View infoButton;
		int position;
	}
}


