<cfscript>
  // Assuming your secret key is stored in a system setting or environment variable
  apiKey = "pk_live_51SDSlpB8uLAkRXyapEJk73CLwJz6VtT5LXMOXkAQtuKgQitj9MLLHMiq7YETndd0rEjHD2HdIoViEh2yFqA2oXOR00rPjnLkhl"; 

  // Create an instance of the component
  stripe = new stripe-cfml.stripe(apiKey=apiKey);
</cfscript>

<cfscript>
stripe = createObject("component", "stripe-cfml");

// Call a method on the instantiated object
result = myObject.myMethod();
</cfscript>


