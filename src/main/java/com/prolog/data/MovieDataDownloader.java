package com.prolog.data;

import java.io.IOException;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class MovieDataDownloader {

	private static final Logger logger = LoggerFactory.getLogger(MovieDataDownloader.class);

	private HttpClient httpClient;
	private HttpGet httpGet;

	public MovieDataDownloader(String dataUrl) {
		this.httpClient = new DefaultHttpClient();
		this.httpGet = new HttpGet(
				dataUrl);
	}

	public void downloadDataAsJson() throws IOException {
		HttpResponse response = httpClient.execute(httpGet);
		if (response.getStatusLine().getStatusCode() != 200) {
			logger.error("Error while download move data, status code: " + response.getStatusLine().getStatusCode());
		} else {
			HttpEntity entity = response.getEntity();
		}
	}
}
