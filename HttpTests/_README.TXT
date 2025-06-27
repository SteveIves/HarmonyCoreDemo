
The .http files in this folder can be used to directly make HTTP calls to test
the endpoints of a web service.

Doing so requires the REST Client Visual Studio extension by Mads Kristensen:

https://marketplace.visualstudio.com/items?itemName=MadsKristensen.RestClient

Also, be aware that at the time of writing (late November 2022) there is a problem
where string parameters don't work if there are any embedded spaces or other
special characters. The value of the parameter must be URL encoded to work.
I have reported this to the maintainer via this GitHub issue.

https://github.com/madskristensen/RestClientVS/issues/36
