package com.ijumboapp;

import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

public class MyFoodAdapter extends ArrayAdapter<JSONObject> {

	private static final int HEADER_ITEM_VIEW_TYPE = 0;
	private static final int ROW_ITEM_VIEW_TYPE = 1;
	Context context;
	int resourceID;
	String[] foodItems;
	boolean isMyFood;
	LoadActivityInterface loadActivity;

	
	public MyFoodAdapter(Context context, int textViewResourceId, String[] foodItems, boolean isMyFood, LoadActivityInterface activity) {
		super(context, textViewResourceId);
		this.context = context;
		this.foodItems = foodItems;
		this.isMyFood = isMyFood;
		this.loadActivity = activity;
	}
	
	
	@Override
	 public View getView(int position, View convertView, ViewGroup parent) {
		LayoutInflater inflater = ((Activity)context).getLayoutInflater();
		if(position == 0) {
			View cellHeader = inflater.inflate(R.layout.listview_header_row, parent, false);
			String header = (this.isMyFood) ? "Click a cell to unsubscribe from it" : "Click a cell to subscribe to it";
			((TextView)cellHeader.findViewById(R.id.txtHeader)).setText(header);
			return cellHeader;
		}
		View cell = convertView;
		Holder holder = null;
		if(cell == null) {
			cell = inflater.inflate(R.layout.listview_item_row, parent, false);
			cell.setOnClickListener((this.isMyFood) ? this.myFoodListener() : this.allFoodListener());
			holder = new Holder();
			holder.tView = (TextView) cell.findViewById(R.id.txtTitle);
			cell.setTag(holder);
		} else {
			holder = (Holder) cell.getTag();
		}
		holder.tView.setText(this.foodItems[position - 1]);
		holder.index = position - 1;
		
		return cell;
	}
	
	private OnClickListener myFoodListener() {
		return new OnClickListener() {
			@Override
			public void onClick(View v) {
				Holder holder = (Holder) v.getTag();
				String foodName = MyFoodAdapter.this.foodItems[holder.index];
				MenuActivity.unsubscribeToFood(foodName, MyFoodAdapter.this.context);
				String[] newFoodData = new String[MyFoodAdapter.this.foodItems.length - 1];
				int newFoodCounter = 0;
				for(int i = 0; i < MyFoodAdapter.this.foodItems.length; i++) {
					if(!MyFoodAdapter.this.foodItems[i].equals(foodName)) {
						newFoodData[newFoodCounter] = MyFoodAdapter.this.foodItems[i];
						newFoodCounter++;
					}
				}
				MyFoodAdapter.this.foodItems = newFoodData;
				MyFoodAdapter.this.notifyDataSetChanged();
			}
		};
	}
	
	private OnClickListener allFoodListener() {
		return new OnClickListener() {
			@Override
			public void onClick(View v) {
				Holder holder = (Holder) v.getTag();
				String foodName = MyFoodAdapter.this.foodItems[holder.index];
				if(foodName != null) {
					MenuActivity.subscribeToFood(foodName, MyFoodAdapter.this.context);
				}
			}
		};
	}
	
	@Override
	public int getCount() {
		// add one to have a header at the top of the list
		// then offset index asked for in the array 
		return this.foodItems.length + 1;
	}
	
	@Override 
	public int getViewTypeCount() {
		// the header and the regular cells
		return 2;
	}
	
	@Override
	public int getItemViewType(int position) {
		if(position == 0) {
			return HEADER_ITEM_VIEW_TYPE;
		}
		return ROW_ITEM_VIEW_TYPE;
	}
	
	private class Holder {
		TextView tView;
		int index;
	}
	

}
