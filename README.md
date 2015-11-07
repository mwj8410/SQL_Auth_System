# SQL_Auth_System

A prototype authorization system in SQL that I pulled out of my dust-bin of a
and file system and started revising.

The underlying concept is that the consuming SQL user will not have access to
the actual data, only the procedures to create, validate, and other
authorization related administration.

The actual authorization data does not include any user supplied information,
only the hash that results from user input and a randomly generated salt. This
should mean that, if the data was revealed, decoding any amount of the encoded
data should not aid in decoding any other piece of data.

I make no claims that this is a secure way to handle authorization. This
project is the results of my musings on how authorization could be done better
than the system that I have direct experience with. Further, this code is
influenced to some degree, I am unsure how much because it has honestly been a
while) by the writing at https://crackstation.net/.



As of this writing (2015-11-07), the table and procedures appear to be working
correctly from a functional standpoint.

The security setting have not been applied and the 'created_by' field is not
being populated or consumed by anything.
