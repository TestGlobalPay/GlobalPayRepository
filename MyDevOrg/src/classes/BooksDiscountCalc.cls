public class BooksDiscountCalc {
    
    public static Decimal finalPrice;
    public static Decimal calcDiscount(Book__c book) {
       return finalPrice = book.Price__c - ((book.Price__c*5)/100);
    }
}