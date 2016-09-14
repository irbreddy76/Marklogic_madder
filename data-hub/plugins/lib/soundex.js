// create object listing the SOUNDEX values for each letter
// -1 indicates that the letter is not coded, but is used for coding
//  0 indicates that the letter is omitted for modern census archives
//                              but acts like -1 for older census archives
//  1 is for BFPV
//  2 is for CGJKQSXZ
//  3 is for DT
//  4 is for L
//  5 is for MN my home state
//  6 is for R
function makesoundex() {
  this.a = -1
  this.b =  1
  this.c =  2
  this.d =  3
  this.e = -1
  this.f =  1
  this.g =  2
  this.h = 0
  this.i = -1
  this.j =  2
  this.k =  2
  this.l =  4
  this.m =  5
  this.n =  5
  this.o = -1
  this.p =  1
  this.q =  2
  this.r =  6
  this.s =  2
  this.t =  3
  this.u = -1
  this.v =  1
  this.w = 0
  this.x =  2
  this.y = -1
  this.z =  2
}

var sndx=new makesoundex()

// check to see that the input is valid
function isSurname(name) {
  if (name=="" || name==null) {
    //alert("Please enter surname for which to generate SOUNDEX code.")
    return false
  } else {
    for (var i=0; i<name.length; i++) {
      var letter=name.charAt(i)
      if (!(letter>='a' && letter<='z' || letter>='A' && letter<='Z')) {
        //alert("Please enter only letters in the surname.")
        return false
      }
    }
  }
  return true
}

// Collapse out directly adjacent sounds
// 1. Assume that surname.length>=1
// 2. Assume that surname contains only lowercase letters
function collapse(surname) {
  if (surname.length==1) {
    return surname
  }
  var right=collapse(surname.substring(1,surname.length))
  if (sndx[surname.charAt(0)]==sndx[right.charAt(0)]) {
    return surname.charAt(0)+right.substring(1,right.length)
  }
  return surname.charAt(0)+right
}

// Collapse out directly adjacent sounds using the new National Archives method
// 1. Assume that surname.length>=1
// 2. Assume that surname contains only lowercase letters
// 3. H and W are completely ignored
function omit(surname) {
  if (surname.length==1) {
    return surname
  }
  var right=omit(surname.substring(1,surname.length))
  if (!sndx[right.charAt(0)]) {
    return surname.charAt(0)+right.substring(1,right.length)
  }
  return surname.charAt(0)+right
}

// Output the coded sequence
function output_sequence(seq)
{
  var output=seq.charAt(0).toUpperCase() // Retain first letter
  output+="-" // Separate letter with a dash
  var stage2=seq.substring(1,seq.length)
  var count=0
  for (var i=0; i<stage2.length && count<3; i++) {
    if (sndx[stage2.charAt(i)]>0) {
      output+=sndx[stage2.charAt(i)]
      count++
    }
  }
  for (; count<3; count++) {
    output+="0"
  }
  return output
}

// Compute the SOUNDEX code for the surname
function soundex(surname) {
  if (!isSurname(surname)) {
    return
  }
  var stage1=collapse(surname.toLowerCase())
  result=output_sequence(stage1);

  var stage1=omit(surname.toLowerCase())
  var stage2=collapse(stage1)
  result=output_sequence(stage2);
  return result;
}
exports.soundex = soundex;