﻿import React from 'react';
import PropTypes from 'prop-types';
import 'antd/dist/antd.css';
import { Row, Col } from 'antd';
import { DATA_SOURCE } from '../constants';

const ContactRow = props => {
  const {
    Id = 0,
    First = '',
    Last = '',
    Email = '',
    Phone1 = ''
  } = props.contact || {};

  return (
    <Row>
      <Col span={2}>
      {DATA_SOURCE === "sqlserver" || DATA_SOURCE === "mongodb" ? (
        <span>
          <i className="fas fa-edit"/>
          <i className="fas fa-trash" />
        </span>
        ) : (
        <span>N/A</span>
      )}
      </Col>
      <Col span={2}>{Id}</Col>
      <Col span={4}>{First}</Col>
      <Col span={4}>{Last}</Col>
      <Col span={8}>{Email}</Col>
      <Col span={4}>{Phone1}</Col>
    </Row>
  )
}

ContactRow.propTypes = {
  contact: PropTypes.shape({
    Id: PropTypes.number,
    First: PropTypes.string,
    Last: PropTypes.string,
    Email: PropTypes.string, 
    Phone1: PropTypes.string
  }).isRequired
};

export default ContactRow;
