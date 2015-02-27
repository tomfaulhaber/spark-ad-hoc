/**
  * Count words in the Open American National Corpus
  * and show the most common ones.
  */
package com.infolace

import org.apache.spark._
import org.apache.spark.SparkContext._

object WordCount {
  val topCount = 30

  def tokenize(text : String) : Array[String] = {
    text.toLowerCase.replaceAll("[^a-zA-Z0-9\\s]", "").split("\\s+")
  }

  def main(args: Array[String]): Unit  = {
    val sc = new SparkContext(new SparkConf().setAppName("OANC Word Count"))
    val file = sc.textFile(s"hdfs://${System.getenv("SPARK_LOCAL_IP")}/user/words/words.txt")
    val words = file.flatMap(tokenize).filter(_.length > 0).cache()
    val totalWords = words.count
    val counts = words.map(word => (word, 1)).reduceByKey(_ + _)
    val commonWords = counts.sortBy(_._2, false).cache()
    val uniqueWords = commonWords.count

    println(s"Total words: $totalWords")
    println(s"Unique words: $uniqueWords")
    println()
    println(s"$topCount most common words:")
    println("Word        Occurrences Percent")
    commonWords.take(topCount).foreach {
      case (word, count) =>
        println(f"$word%-15s $count%7d ${(count*100.0)/totalWords}%5.3f%%")
    }
  }
}
