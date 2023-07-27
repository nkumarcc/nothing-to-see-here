import React, { useState } from "react";
import { Button, Col, Form, Input, Row } from 'reactstrap';
import './styles/AskBookForm.scss';
import axios from 'axios';

const AskBookForm: React.FC = () => {

  const handleAsk = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    console.log('form submitted with val: ', event.currentTarget.bookQuestion.value);
    const response = await axios.post('/ask', {
      question: event.currentTarget.bookQuestion.value
    });
    console.log('form responded with the first letter! It\'s: ', response.data.answer);
  }

  const handleFeelingLucky = async (event: React.MouseEvent<HTMLButtonElement, MouseEvent>) => {
    event.preventDefault();
    console.log('feeling lucky button clicked');
    const response = await axios.get('/feeling-lucky');
    console.log('feeling lucky response', response.data);
  }

  return (
    <Form className="askBookFormContainer" onSubmit={handleAsk}>
      <Row>
        <Input name="bookQuestion" type="textarea" />
      </Row>
      <Row className="mt-3">
        <Col>
          <Button type="submit" className="me-1">Ask Question</Button>
          <Button type="button" className="ms-1" onClick={handleFeelingLucky}>I'm Feeling Lucky</Button>
        </Col>
      </Row>
    </Form>
  );
};

export default AskBookForm;
