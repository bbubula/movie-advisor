package com.prolog.knowledge.generator;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;

import java.io.*;
import java.util.Arrays;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Read CSV records from provided file and saves transformed items into output file.
 */
public class KnowledgeBaseGenerator {
    private final FileReader reader;
    private final PrintWriter writer;
    private final CSVParser parser;
    private final int linesToSkip;

    private AtomicInteger handledItemsCounter = new AtomicInteger(0);

    public KnowledgeBaseGenerator(String input, String output, boolean isInputFileWithHeader) throws IOException {
        this.reader = new FileReader(new File(input));
        this.writer = new PrintWriter(new FileOutputStream(new File(output)));
        this.parser = new CSVParser(reader, CSVFormat.DEFAULT);
        this.linesToSkip = isInputFileWithHeader ? 1 : 0;
    }

    /**
     * Transforms CSV records to knowledge premises. Writes premises to file.
     * Method does not use: NUM_CRITIC_FOR_REVIEWS, GROSS, NUM_VOTED_USERS, FACENUMBER_IN_POSTER, NUM_USER_FOR_REVIEWS.
     */
    public void run() throws IOException {
        parser.getRecords().stream().skip(linesToSkip).forEach(record -> {
            addMoviePremise("movieCreatedInYear(%s, %s)", record.get(Indexes.TITLE_YEAR));
            addMoviePremise("movieCreatedInCountry(%s, \"%s\")", record.get(Indexes.COUNTRY));
            addMoviePremise("movieHasRankValue(%s, %s)", record.get(Indexes.IMDB_SCORE));
            addMoviePremise("movieHasContentValue(%s, \"%s\")", record.get(Indexes.CONTENT_RATING));
            addMoviePremise("movieHasTitle(%s, \"%s\")", record.get(Indexes.MOVIE_TITLE));
            addMoviePremise("movieInLanguage(%s, \"%s\")", record.get(Indexes.LANGUAGE));
            addMoviePremise("movieOfDuration(%s, %s)", record.get(Indexes.DURATION));
            addMoviePremise("movieWithFame(%s, %s)", record.get(Indexes.MOVIE_FACEBOOK_LIKES));
            addMoviePremise("movieHyperlink(%s, \"%s\")", record.get(Indexes.MOVIE_IMDB_LINK));
            addMoviePremise("movieHadBudget(%s, %s)", record.get(Indexes.BUDGET));
            addMoviePremise("movieColor(%s, \"%s\")", record.get(Indexes.COLOR));
            addMoviePremise("movieHasAspectRatio(%s, %s)", record.get(Indexes.ASPECT_RATIO));
            addMovieHumanReadableInfo("movieHasHumanReadableDescription(%s, \"%s\")", record);

            addMoviePremise("movieDirectedBy(%s, \"%s\")", record.get(Indexes.DIRECTOR_NAME));
            addPremise("directorWithFame(\"%s\", %s)",
                    record.get(Indexes.DIRECTOR_NAME), record.get(Indexes.DIRECTOR_FACEBOOK_LIKES));

            addMoviePremise("movieWithActorInCast(%s, \"%s\")", record.get(Indexes.ACTOR_1_NAME));
            addMoviePremise("movieWithActorInCast(%s, \"%s\")", record.get(Indexes.ACTOR_2_NAME));
            addMoviePremise("movieWithActorInCast(%s, \"%s\")", record.get(Indexes.ACTOR_3_NAME));
            addMoviePremise("movieWithTotalActorFame(%s, %s)", record.get(Indexes.CAST_TOTAL_FACEBOOK_LIKES));
            addPremise("actorWithFame(\"%s\", %s)", record.get(Indexes.ACTOR_1_NAME), record.get(Indexes.ACTOR_1_FACEBOOK_LIKES));
            addPremise("actorWithFame(\"%s\", %s)", record.get(Indexes.ACTOR_2_NAME), record.get(Indexes.ACTOR_2_FACEBOOK_LIKES));
            addPremise("actorWithFame(\"%s\", %s)", record.get(Indexes.ACTOR_3_NAME), record.get(Indexes.ACTOR_3_FACEBOOK_LIKES));

            addMoviePremiseForEveryItem("movieWithPlotKeyword(%s, \"%s\")", parseMultiValue(record, Indexes.PLOT_KEYWORDS));
            addMoviePremiseForEveryItem("movieOfGenre(%s, \"%s\")", parseMultiValue(record, Indexes.GENRES));

            handledItemsCounter.getAndIncrement();
            handlePeriodicFlush();
        });
        ensureBuffersFlushed();
    }

    private void ensureBuffersFlushed() {
        writer.flush();
    }

    private void addMovieHumanReadableInfo(String strucutre, CSVRecord record) {
        String info =
                String.format("Film '%s' created in year %s, directed by %s is available here: %s - enjoy!",
                        record.get(Indexes.MOVIE_TITLE).trim(),
                        record.get(Indexes.TITLE_YEAR).trim(),
                        record.get(Indexes.DIRECTOR_NAME).trim(),
                        record.get(Indexes.MOVIE_IMDB_LINK).trim());

        addMoviePremise(strucutre, info);
    }

    private String[] parseMultiValue(CSVRecord record, int index) {
        return record.get(index).split("\\|");
    }

    private void addMoviePremiseForEveryItem(String structure, String[] items) {
        Arrays.asList(items)
                .forEach(item -> addMoviePremise(structure, item.trim()));
    }

    private void handlePeriodicFlush() {
        if (handledItemsCounter.get() % 10 == 0) {
            writer.flush();
        }
    }

    private void addMoviePremise(String structure, String param) {
        addPremise(structure, handledItemsCounter.get(), param);
    }

    private void addPremise(String structure, Object key, String value) {
        String premise = String.format(structure, key.toString().trim(), value.trim());
        premise = premise.endsWith(".") ? premise : (premise + '.');
        premise = premise.replaceAll(" ", "");
        writer.println(premise);
    }
}
