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
	private Map<String, String> urls;
	private Spinner newsSpinner;
	private Spinner newsSectionsSpinner;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_news);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_news, menu);
        this.newsSpinner = (Spinner) menu.findItem(R.id.newsSpinner).getActionView();
        this.newsSectionsSpinner = (Spinner) menu.findItem(R.id.newsSectionSpinner).getActionView();
        this.newsSectionsSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
			@Override
			public void onItemSelected(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
				NewsActivity.this.displayDataBasedOnUI();
			}
			@Override
			public void onNothingSelected(AdapterView<?> arg0) {}
        });
        
        this.newsSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
			@Override
			public void onItemSelected(AdapterView<?> arg0, View arg1,
					int arg2, long arg3) {
				// change the array used in the news sections spinner then reload the data
			     String[] sections = null; 
			     if(NewsActivity.this.newsSpinner.getSelectedItem().toString().equals("Observer")) {
			    	 sections = getResources().getStringArray(R.array.observer_sections);
			     } else if(NewsActivity.this.newsSpinner.getSelectedItem().toString().equals("Daily")) {
			    	 sections = getResources().getStringArray(R.array.daily_sections); 
			     }
			     ArrayAdapter<String> adapter = new ArrayAdapter<String>(NewsActivity.this, android.R.layout.simple_spinner_dropdown_item, sections);
		    	 NewsActivity.this.newsSectionsSpinner.setAdapter(adapter);
		    	 NewsActivity.this.displayDataBasedOnUI();
			}
			@Override
			public void onNothingSelected(AdapterView<?> arg0) {}
		});
        new Thread(new ActivityLoadThread(this)).start();
        
        return true;
    }
    
    public void loadData() {
    	// get the xml
    	System.out.println("THE URL FROM THE UI: " + this.getURL());
    	String xml = new RequestManager().get(this.getURL());
    	// load binary of the xml into a stream
    	InputStream inStream = new ByteArrayInputStream(xml.getBytes());
    	boolean didParse = true;
    	try {
    		// parse through it
			this.parseThatIsh(inStream);
		} catch (XmlPullParserException e) {
			didParse = false;
			System.out.print(e);
		} catch (IOException e) {
			didParse = false;
			System.out.print(e);
		}
    	
    	if(didParse) {
    		// TODO -- add the data to a hash table of already loaded news stories for faster loads in e future
    	}
     }
    
    // just load the data by calling the background thread
    private void displayDataBasedOnUI() {
    	// TODO -> implement this to to shit
    	System.out.println("LOADING DATA BASED ON THE UI\n----------DO SOME SHIT HERE----------");
    	new Thread(new ActivityLoadThread(this)).start();
    }
    
    // change this so it grabs stuff from the UI and gets the correct url
    // put in big if else instead of grabbing the url from a hashtable
    private String getURL() {
    	String urlKey = this.newsSpinner.getSelectedItem().toString() + "-" + 
    					this.newsSectionsSpinner.getSelectedItem().toString();
    	System.out.println("the news url key that is going to be used: " + urlKey);
    	// the getter will create the hash table if it does not exist yet
    	// then return the url from that hash table
    	return this.getUrls().get(urlKey);
    }
    
    private void parseThatIsh(InputStream inStream) throws XmlPullParserException, IOException {
    	XmlPullParserFactory factory = XmlPullParserFactory.newInstance();
        factory.setNamespaceAware(true);
        XmlPullParser xpp = factory.newPullParser();
        // TODO -- THIS CRASHES FOR SOME REASON WHEN USING THE OBSERVER
        xpp.setInput(inStream, null);
        int eventType = xpp.getEventType();
        while (eventType != XmlPullParser.END_DOCUMENT) {
        	//System.out.println("GOING THROUGH THE XML");
        	if(eventType == XmlPullParser.START_DOCUMENT) {
        		this.articles = new ArrayList<Article>();
        		this.currentArticle = new Article();
        	} else if(eventType == XmlPullParser.START_TAG) {
        		this.currentTag = xpp.getName();
        		if(this.currentTag.equals("item")) {
        			this.currentArticle = new Article();
        		}
        	} else if(eventType == XmlPullParser.END_TAG) {
        		String endTag = xpp.getName();
        		if(endTag.equals("item")) {
        			this.articles.add(this.currentArticle);
        			System.out.println("ADDING THE ARtiCLE");
        		}
        	} else if(eventType == XmlPullParser.TEXT) {
        		if(isValidTag(this.currentTag, this.currentArticle)) {
        			this.currentArticle.addFieldFromRss(this.currentTag, xpp.getText());
        		}
        	}
        	eventType = xpp.next();
        }
        System.out.println("AT THE END OF THIS BITCH");
        System.out.println("THE ARTICLES WE GOT: " + this.articles);
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

	public Map<String, String> getUrls() {
		if(urls == null) {
			System.out.println("urls was null so i made one");
			urls = new HashMap<String, String>();
			// The Daily
			urls.put("Daily-Main", "http://www.tuftsdaily.com/se/tufts-daily-rss-1.445827");
			urls.put("Daily-News", "http://www.tuftsdaily.com/se/tufts-daily-news-rss-1.445867");
			urls.put("Daily-Features", "http://www.tuftsdaily.com/se/tufts-daily-features-rss-1.445868");
			urls.put("Daily-Arts", "http://www.tuftsdaily.com/se/tufts-daily-arts-rss-1.445870");
			urls.put("Daily-Op-Ed", "http://www.tuftsdaily.com/se/tufts-daily-op-ed-rss-1.445869");
			urls.put("Daily-Sports", "http://www.tuftsdaily.com/se/tufts-daily-sports-rss-1.445871");
			// The Observer
			urls.put("Observer-Arts", "http://tuftsobserver.org/category/arts-culture/feed");
			urls.put("Observer-Campus", "http://tuftsobserver.org/category/campus/feed");
			urls.put("Observer-News", "http://tuftsobserver.org/category/news-features/feed");
			urls.put("Observer-Off Campus", "http://tuftsobserver.org/category/off-campus/feed");
			urls.put("Observer-Opinion", "http://tuftsobserver.org/category/opinion/feed");
			urls.put("Observer-Poetry", "http://tuftsobserver.org/category/poetry-prose/feed");
			urls.put("Observer-Extras", "http://tuftsobserver.org/category/extras/feed");
		}
		return urls;
	}

	public void setUrls(Map<String, String> urls) {
		this.urls = urls;
	}
	

}
