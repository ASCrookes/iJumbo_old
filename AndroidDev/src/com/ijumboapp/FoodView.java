package com.ijumboapp;

import org.json.JSONException;
import org.json.JSONObject;

import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.TextView;


public class FoodView extends IJumboActivity {

	String foodName;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_food);
		
		Intent intent = getIntent();
		JSONObject obj = null;
		try {
			obj = new JSONObject(intent.getStringExtra("foodItem"));
			this.displayData(obj);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_food, menu);	
		return true;
	}
	
	@Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle item selection
        switch (item.getItemId()) {
        case R.id.foodAlert:
        	MenuActivity.subscribeToFood(this.foodName, this);
        	break;
        default:
        	break;
        }
        return true;
    }
	
	private void displayData(JSONObject data) throws JSONException {
		this.foodName = data.getString("FoodName");
		this.setTitle(this.foodName);
		((TextView)findViewById(R.id.calories)).setText(data.getString("calories"));
		((TextView)findViewById(R.id.servingSize)).setText(data.getString("serving_size"));
		((TextView)findViewById(R.id.fatCalories)).setText(data.getString("fat_calories"));
		((TextView)findViewById(R.id.carbs)).setText(data.getString("total_carbs"));
		((TextView)findViewById(R.id.satFat)).setText(data.getString("saturated_fat"));
		((TextView)findViewById(R.id.fiber)).setText(data.getString("fiber"));
		((TextView)findViewById(R.id.sugars)).setText(data.getString("sugars"));
		((TextView)findViewById(R.id.cholestoral)).setText(data.getString("cholesterol"));
		((TextView)findViewById(R.id.protein)).setText(data.getString("protein"));
		((TextView)findViewById(R.id.sodium)).setText(data.getString("sodium"));
	}

}
