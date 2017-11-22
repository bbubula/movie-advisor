package com.prolog.streamsmanager;

import java.io.File;
import java.io.IOException;
import java.util.Observable;

import org.apache.commons.io.FileUtils;

public class QuestionObservable extends Observable {

	public void readQuestion() throws IOException, InterruptedException {
		String currentQuestion = "";
		String question = FileUtils.readFileToString(new File("out.txt"));
		while (!question.equals("end")) {
			if (!question.equals(currentQuestion)) {
				System.out.println("New question appear.");
				setChanged();
				notifyObservers(question);
				currentQuestion = question;
			}
			Thread.sleep(1000);
			question = FileUtils.readFileToString(new File("out.txt"));
		}
	}
}
