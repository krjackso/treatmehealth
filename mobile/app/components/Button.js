import React, { Component } from 'react'
import { Text, TouchableHighlight } from 'react-native'
import { TREATME_BLUE } from '../styles'

export default class Button extends Component {
  render() {
    return (
      <TouchableHighlight
        style={{
          flex: 1,
          flexDirection: 'row',
          alignItems: 'center',
          borderWidth: 1,
          borderRadius: 10,
          borderColor: 'transparent',
          backgroundColor: TREATME_BLUE,
          padding: 10,
          opacity: this.props.disabled ? 0.5 : 1.0,
          ...this.props.style
        }}
        disabled= {this.props.disabled}
        underlayColor= 'transparent'
        onPress= {this.props.onPress}
      >
        <Text style={{flex: 1, color: 'white', textAlign: 'center'}}>{this.props.text}</Text>
      </TouchableHighlight>
    )
  }
}
