import React, { StyleSheet } from 'react-native';

export const TREATME_RED = '#E71D36'
export const TREATME_PURPLE = '#540D6E'
export const TREATME_ORANGE = '#FF7733'
export const TREATME_GREEN = '#81C14B'
export const TREATME_BLUE = '#067BC2'

export default StyleSheet.create({
  input: {
    borderWidth: 1,
    borderColor: 'black',
    borderRadius: 5,
    backgroundColor: 'white',
    padding: 5,
    paddingLeft: 15,
    marginBottom: 10,
    height: 40
  },
  inputText: {
    fontSize: 16,
    color: 'black'
  },
  placeholderText: {
    fontSize: 16,
    color: 'lightgray'
  }
});
