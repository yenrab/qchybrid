package org.quickconnectfamily.hybrid.commandobjects;

import java.io.File;
import java.io.FileOutputStream;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.HashMap;

import org.quickconnect.ControlObject;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Environment;

public class CacheResourcesBCO implements ControlObject {

	@SuppressWarnings("unchecked")
	@Override
	public Object handleIt(HashMap<String, Object> parameters) {
		System.out.println("Caching Resources");
		
		ArrayList<Object>params = (ArrayList<Object>)parameters.get("parameters");
		ArrayList<String>urls   = (ArrayList<String>)params.get(0);
		
		final HashMap<String, String> cachedUrls = new HashMap<String, String>(); // All the urls that are successfully cached will go in here...
				
		// START Break it into batches so that we don't have it spawn 100 threads if we are caching 100 resources
		int batchSize = 4;
		int numBatches = (urls.size() / batchSize) + 1;
		
		for (int i = 0; i < numBatches; i++) {
			ArrayList<String> batch = new ArrayList<String>();
			int startingIndex = batchSize * i;
			for (int j = 0; j < batchSize; j++) {
				int index = j + startingIndex;
				if (index < urls.size()) {
					batch.add(urls.get(index));
				}
			}
			
			handleBatchOfUrls(batch, cachedUrls);
		}
		// END break into batches
		
		System.out.println("Finished processing resources to cache.");
		
		parameters.put("cacheResult", cachedUrls);
		
		return true;
	}
	
	private void handleBatchOfUrls(ArrayList<String> batch, final HashMap<String, String> cachedUrls) {
		// Make sure the appropriate folders exist
		Thread[] threads = new Thread[batch.size()];
		String path = Environment.getExternalStorageDirectory().toString();
		final File folder = new File(path , "/Android/data/com.affinityamp.hybrid/files/ResourceCache");
		folder.mkdirs();
		
		int arrayLength = batch.size();
		for (int i = 0; i < arrayLength; i++) {
			final String stringURL = batch.get(i);
			
			Runnable theRunnable = new Runnable() {
				@Override
				public void run() {
					try {
						System.out.println("Caching a resource");
						URL theUrl = new URL(stringURL);
						URLConnection yc = theUrl.openConnection();
						Bitmap bitmap = BitmapFactory.decodeStream(yc.getInputStream());
						if (bitmap != null) { // If it returns null, it couldn't decode the image properly. Might not be an image at all.
							File full   = new File(theUrl.getFile());
					        File file   = new File(folder, full.getName());
					        file.createNewFile();
					        FileOutputStream fOut = new FileOutputStream(file);
					        bitmap.compress(getImageCompressFormatForFile(file), 85, fOut);
				            fOut.flush();
				            fOut.close();
				            
				            cachedUrls.put(stringURL, file.toURI().toString()); // We finished caching, woot! 
						}
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
			};
			
			Thread theThread = new Thread(theRunnable);
			threads[i] = theThread;
			theThread.start();
		}
		
		// Wait for them all to finish!
		for (int i = 0; i < threads.length; i++) {
		    try {
		       threads[i].join();
		    } catch (InterruptedException ignore) {}
		}
	}
	
	private Bitmap.CompressFormat getImageCompressFormatForFile(File aFile) {
		if(aFile.toString().endsWith(".png")) {
			return Bitmap.CompressFormat.PNG;
		}
		
		return Bitmap.CompressFormat.JPEG;
	}
}
