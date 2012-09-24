package edu.tufts.mobile;

import android.os.Bundle;
import android.app.Activity;
import android.content.Intent;
import android.view.Menu;
import android.view.View;
import android.widget.ImageButton;


public class TM_Main extends Activity {
	ImageButton placesButton;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_tm__main);

        placesButton = (ImageButton) findViewById(R.id.imageButton1);
    }
    
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_tm__main, menu);
        return true;
    }

    public void onPlacesClick(View view)	{
    	Intent intent = new Intent(this, Places.class);
    	startActivity(intent);
    }
 
    public void onJoeyClick(View view)	{
    	Intent intent = new Intent(this, Joey.class);
    	startActivity(intent);
    }
    
    public void onTrunkClick(View view)	{
    	Intent intent = new Intent(this, Trunk.class);
    	startActivity(intent);
    }

    public void onMenusClick(View view)	{
    	Intent intent = new Intent(this, Menus.class);
    	startActivity(intent);
    }

    public void onEventsClick(View view)	{
    	Intent intent = new Intent(this, Events.class);
    	startActivity(intent);
    }

    public void onMapClick(View view)	{
    	Intent intent = new Intent(this, Map.class);
    	startActivity(intent);
    }
}
