package com.ijumboapp;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Set;

import org.json.JSONArray;
import org.json.JSONException;

import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.Spinner;

import com.parse.PushService;

public class MyFoodActivity extends IJumboActivity implements LoadActivityInterface {

	// update the food after 30 minutes
	final int UPDATE_TIME = 1800;
	
	MenuItem menuItem;
	Spinner myFoodSpinner;
	String[] allFood;
	Date allFoodDownload;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_my_food);
		this.allFood = null;
		
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_my_food, menu);
		this.myFoodSpinner = (Spinner) menu.findItem(R.id.myFood_spinner).getActionView();
		this.myFoodSpinner.setOnItemSelectedListener(new OnItemSelectedListener() {

			@Override
			public void onItemSelected(AdapterView<?> arg0, View arg1,
									              int arg2, long arg3) {
				new Thread(new ActivityLoadThread(MyFoodActivity.this)).start();
			}

			@Override
			public void onNothingSelected(AdapterView<?> arg0) {}
		});
		new Thread(new ActivityLoadThread(this)).start();
		return true;
	}
	
	@Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle item selection
		/*
        switch (item.getItemId()) {
        case R.id.myFoodToggle:
        	this.menuItem.setTitle((this.menuItem.getTitle().equals("My Food")) ? "All Food" : "My Food");
        	new Thread(new ActivityLoadThread(this)).start();
        	break;
        default:
        	break;
        }
        */
        return true;
    }

	@Override
	public void loadData() throws JSONException {
		String[] foodItems = null;
		boolean myFoodList = this.myFoodSpinner.getSelectedItem().toString().equals("My Food");
		if(myFoodList) {
			foodItems = this.getMyFood();
		} else {
			foodItems = this.allFood;
			// do this to avoid loading data from the server everytime
			if(foodItems == null || (new Date().getTime() - this.allFoodDownload.getTime())  >= UPDATE_TIME) {
				foodItems = this.getAllFoodFromServer();
				this.allFood = foodItems;
				this.allFoodDownload = new Date();
			}
		}
		if(foodItems == null) {
			return;
		}

		final MyFoodAdapter adapter = new MyFoodAdapter(this, R.layout.listview_item_row, foodItems, myFoodList, this);
		final ListView lView = (ListView) findViewById(R.id.myFoodList);
		this.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				lView.setAdapter(adapter);
			}
		});
	}
	
	public String[] getMyFood() {
		Set<String> myFoodSet = PushService.getSubscriptions(this);
		Object[] myFoodObjs =  myFoodSet.toArray();
		
		List<String> myFoodList = new ArrayList<String>();
		for(int i = 0; i < myFoodObjs.length; i++) {
			// all subscribers have the master channel ""
			if(!myFoodObjs[i].equals("")) {
				myFoodList.add(myFoodObjs[i].toString()
					  			.replace("ASC_", "")
					  			.replace("_", " ")
					  			.replace("--and--", "&"));
			}
		}
		return myFoodList.toArray(new String[myFoodList.size()]);
	}
	
	private String[] getAllFoodFromServer() {
		JSONArray allFoodJSON = null;
		String[] allFood = null;
		try {
			allFoodJSON = new RequestManager().getJSONArray("http://ijumboapp.com/api/allFood");
			allFood = new String[allFoodJSON.length()];
			for(int i = 0; i < allFood.length; i++) {
				allFood[i] = allFoodJSON.getString(i);
			}
		} catch (JSONException e) {}
		if(allFoodJSON == null) {
			return new String[0];
		}
		return allFood;
	}

	@Override
	public void stopLoadingUI() {
		this.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				((ProgressBar)MyFoodActivity.this.findViewById(R.id.myFoodPD)).setVisibility(View.INVISIBLE);
			}
		});
	}

	@Override
	public void startLoadingUI() {
		this.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				((ProgressBar)MyFoodActivity.this.findViewById(R.id.myFoodPD)).setVisibility(View.VISIBLE);
			}
		});
	}

}
