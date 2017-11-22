package com.prolog.streamsmanager;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Observable;
import java.util.Observer;
import java.util.Scanner;

public class QuestionObserver implements Observer {

	@Override
	public void update(Observable o, Object arg) {
		System.out.println("Got new question: ");
		String question = ((String) arg).replaceAll("-", "");
		System.out.println(question);

		Scanner scanner = new Scanner(System.in);
		String input = scanner.next();
		input += ".";
		try {
			Files.write(Paths.get("in.txt"), input.getBytes());
		} catch (IOException e) {
			e.printStackTrace();
		}
		System.out.println("Your answer: " + input + " was write.");
	}
}
