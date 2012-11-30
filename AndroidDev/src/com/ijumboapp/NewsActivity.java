package com.ijumboapp;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;
import org.xmlpull.v1.XmlPullParserFactory;

import android.app.Activity;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.Spinner;

public class NewsActivity extends Activity implements LoadActivityInterface {

	private List <Article> articles;
	private Article currentArticle;
	private String currentTag;
	private Map<String, List<Article> > stories;
	// private Spinner newsSpinner;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_news);
        new Thread(new ActivityLoadThread(this)).start();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_news, menu);
        Spinner newsSpinner = (Spinner) menu.getItem(R.id.newsSpinner).getActionView();
        newsSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {

			@Override
			public void onItemSelected(AdapterView<?> arg0, View arg1,
					int arg2, long arg3) {
				NewsActivity.this.displayDataBasedOnUI();
				System.out.println("SELECTED FROM THE NEWS SPINNER");
			}

			@Override
			public void onNothingSelected(AdapterView<?> arg0) {}
		});
        return true;
    }
    
    
    public void loadData() {
    	// get the xml
    	String xml = new RequestManager().get(this.getURL());
    	// load it into a stream
    	InputStream inStream = new ByteArrayInputStream(xml.getBytes());
    	try {
    		// parse through it
			this.parseThatIsh(inStream);
		} catch (XmlPullParserException e) {
			System.out.print(e);
		} catch (IOException e) {
			System.out.print(e);
		}
     }
    
    private void displayDataBasedOnUI() {
    	// TODO -> implement this to to shit
    }
    
    // change this so it grabs stuff from the UI and gets the correct url
    // put in big if else instead of grabbing the url from a hashtable
    private String getURL() {
    	String url = "http://www.tuftsdaily.com/se/tufts-daily-rss-1.445827";
    	return url;
    }
    
    private void parseThatIsh(InputStream inStream) throws XmlPullParserException, IOException {
    	XmlPullParserFactory factory = XmlPullParserFactory.newInstance();
        factory.setNamespaceAware(true);
        XmlPullParser xpp = factory.newPullParser();
        	
        xpp.setInput(inStream, null);
        int eventType = xpp.getEventType();
        while (eventType != XmlPullParser.END_DOCUMENT) {
        	if(eventType == XmlPullParser.START_DOCUMENT) {
        		this.articles = new ArrayList<Article>();
        		this.currentArticle = new Article();
        	} else if(eventType == XmlPullParser.START_TAG) {
        		this.currentTag = xpp.getName();
        		if(this.currentTag.equals("item")) {
        			this.currentArticle = new Article();
        		}
        	} else if(eventType == XmlPullParser.END_TAG) {
        		//System.out.println(xpp.getName());
        		String endTag = xpp.getName();
        		if(endTag.equals("item")) {
        			this.articles.add(this.currentArticle);
        			//this.currentArticle = null;
        		}
        		//System.out.println(endTag);
        	} else if(eventType == XmlPullParser.TEXT) {
        		if(isValidTag(this.currentTag, this.currentArticle)) {
        			//System.out.println("GOT AN END");
        			this.currentArticle.addFieldFromRss(this.currentTag, xpp.getText());
        		}
        	}
        	eventType = xpp.next();
        }
        //System.out.println("AT THE END OF THE NEWS JAHNT");
        final ListView listV = (ListView) findViewById(R.id.newsList);
        Article[] articlesList = new Article[this.articles.size()];
        this.articles.toArray(articlesList);
        final ArrayAdapter<Article> adapter =  new ArrayAdapter<Article>(this, android.R.layout.simple_list_item_1, android.R.id.text1, articlesList);
        this.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				listV.setAdapter(adapter);				
			}
		});
        
        //this.dataSource = this.events;
    }
    
    static private boolean isValidTag(String tag, Article article) {
    	return     (tag.equals("title") && article.title.equals("N/A"))
    			|| (tag.equals("link") && article.link.equals("N/A"))
    			|| (tag.equals("author") && article.author.equals("N/A"))
    			|| (tag.equals("media:thumbnail") && article.imageURL.equals("N/A"));
    }

	@Override
	public void stopLoadingUI() {
		// TODO Auto-generated method stub
	}

	@Override
	public void startLoadingUI() {
		// TODO Auto-generated method stub
	}

	public Map<String, List<Article> > getStories() {
		System.out.println("GETTING STORIES");
		if(stories == null) {
			System.out.println("STORIES WAS NULL SO I CREATED ONE");
			stories = new HashMap< String, List<Article> >();
		}
		return stories;
	}

}
