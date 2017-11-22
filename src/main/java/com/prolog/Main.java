package com.prolog;

import java.io.File;
import java.io.IOException;

import com.prolog.streamsmanager.QuestionObservable;
import com.prolog.streamsmanager.QuestionObserver;

public class Main {

	public static void main(String[] args) {

		PrologQueryExecutor prologQueryExecutor = new PrologQueryExecutor(new File("test11.pl"));
		prologQueryExecutor.consultFile();
		Runnable r1 = () -> prologQueryExecutor.executeQuery("ask('Lubisz mnie? (y/n)')");
		Thread t1 = new Thread(r1);
		t1.start();

		QuestionObservable questionObservable = new QuestionObservable();
		QuestionObserver questionObserver = new QuestionObserver();
		questionObservable.addObserver(questionObserver);

		Runnable r2 = () -> {
			try {
				questionObservable.readQuestion();
			} catch (IOException e) {
				e.printStackTrace();
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		};
		Thread t2 = new Thread(r2);
		t2.start();
	}
}


