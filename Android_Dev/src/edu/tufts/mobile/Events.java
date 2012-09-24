package edu.tufts.mobile;

/*import android.app.Activity;
import android.os.Bundle;

public class Events extends Activity {

	@Override
	public void onCreate(Bundle savedInstanceState){
		super.onCreate(savedInstanceState);
		setContentView(R.layout.tm_events);
	}
	
}*/

import android.app.Activity;
import android.os.Bundle;
//import java.util.Stack;
import android.widget.TextView;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
//import java.util.StringTokenizer;

//import java.net.MalformedURLException;
import java.net.URL;
import org.xml.sax.InputSource;
import org.xml.sax.XMLReader;
import java.io.IOException;
import org.xml.sax.SAXException;
import javax.xml.parsers.ParserConfigurationException;

import org.xml.sax.Attributes;
//import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

public class Events extends Activity {
    /** Called when the activity is first created. */
    String rssResult = "";
    boolean item = false;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.tm_events);
        TextView rss = (TextView) findViewById(R.id.rss);
        try {
            URL rssUrl = new URL("http://www.javaworld.com/index.xml");
            SAXParserFactory factory = SAXParserFactory.newInstance();
            SAXParser saxParser = factory.newSAXParser();
            XMLReader xmlReader = saxParser.getXMLReader();
            RSSHandler rssHandler = new RSSHandler();
            xmlReader.setContentHandler(rssHandler);
            InputSource inputSource = new InputSource(rssUrl.openStream());
            xmlReader.parse(inputSource);

        } catch (IOException e) {rss.setText(e.getMessage());
        } catch (SAXException e) {rss.setText(e.getMessage());
        } catch (ParserConfigurationException e) {rss.setText(e.getMessage());
        }

        rss.setText(rssResult);
    }
    /**public String removeSpaces(String s) {
          StringTokenizer st = new StringTokenizer(s," ",false);
          String t="";
          while (st.hasMoreElements()) t += st.nextElement();
          return t;
        }*/
    private class RSSHandler extends DefaultHandler {

        public void startElement(String uri, String localName, String qName,
                Attributes attrs) throws SAXException {
            if (localName.equals("item"))
                item = true;

            if (!localName.equals("item") && item == true)
                rssResult = rssResult + localName + ": ";

        }

        public void endElement(String namespaceURI, String localName,
                String qName) throws SAXException {

        }

        public void characters(char[] ch, int start, int length)
                throws SAXException {
            String cdata = new String(ch, start, length);
            if (item == true)
                rssResult = rssResult +(cdata.trim()).replaceAll("\\s+", " ")+"\t";

        }

    }
}