# CrateDB SQL Statement request
{
   stmt: ($sql | gsub("YYYYMMDD-HHMMSS"; $timestamp) ) 
}