# project-for-Dušan

•	final dataset from which we will be able to see avarage rating for specific book (the source dataset coudl be found here: http://www2.informatik.uni-freiburg.de/~cziegler/BX/)

SELECT
     bx_books.ISBN, bx_books.Book_Title, AVG("Book-Rating") AS "Book Rating"
FROM
    bx_book_ratings, bx_books
WHERE 
	bx_book_ratings.ISBN = bx_books.ISBN;
  
•	functionality for adding new book to a database

INSERT INTO `bx_books` VALUES ('ISBN','Booktitle','Book-Author',Year-Of-Publication,'Publisher','Image-URL-S',Image-URL-M','Image-URL-L');

•	functionality for adding new rating of a book

INSERT INTO `bx-book-Ratings` VALUES (User-ID,'ISBN',Book-Rating);

•	functionality for searching a book 

SELECT * FROM `bx_books` WHERE Book_Title='dd' ORDER BY "Year-Of-Publication";

•	schema of cloud architecture

![Untitled](https://user-images.githubusercontent.com/30750074/209998675-7bddfd6b-b989-4552-9e2d-6d0fe8057606.jpg)

•	ideas how would CI/CD pipeline work

1. Author will write the code and create a repository.
2. Code Repository will contain our SQL scripts and infrastructure files.
3. There will be Continuous integration and test where we will build our app, generate SQL scripts and run tests to make sure that everything is running perfectly.
4. We need to realise continous deployments where will provision the infrastructure, deploy our app and SQL scripts.
5. Keep monitoring and improving our project.
