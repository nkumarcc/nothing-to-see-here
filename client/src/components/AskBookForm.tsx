import React, { useState } from "react";
import { Button, Col, Form, Input, Row } from 'reactstrap';
import './styles/AskBookForm.scss';
import axios from 'axios';

const AskBookForm: React.FC = () => {
  const [answer, setAnswer] = useState('');

  const handleAsk = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const response = await axios.post('/ask', {
      question: event.currentTarget.bookQuestion.value
    });
    setAnswer(response.data.answer)
  }

  const handleFeelingLucky = async (event: React.MouseEvent<HTMLButtonElement, MouseEvent>) => {
    event.preventDefault();
    console.log('feeling lucky button clicked');
    const response = await axios.get('/feeling-lucky');
    console.log('feeling lucky response', response.data);
  }

  const handleAnotherQuestion = (event: React.MouseEvent<HTMLButtonElement, MouseEvent>) => {
    event.preventDefault();
    setAnswer('');
  }

  function renderButtonsAndAnswer() {
    if (answer) {
      return (
        <div className="text-start">
          <Row className="mt-3">
            <Col>
              <h3>{answer}</h3>
            </Col>
          </Row>
          <Row className="mt-3">
            <Col>
              <Button type="button" onClick={handleAnotherQuestion}>Ask another question</Button>
            </Col>
          </Row>
        </div>
      )
    } else {
      return (
        <Row className="mt-3">
          <Col>
            <Button type="submit" className="me-1">Ask Question</Button>
            <Button type="button" className="ms-1" onClick={handleFeelingLucky}>I'm Feeling Lucky</Button>
          </Col>
        </Row>
      )
    }
  }

  return (
    <Form className="askBookFormContainer" onSubmit={handleAsk}>
      <Row>
        <Input name="bookQuestion" type="textarea" />
      </Row>
      {renderButtonsAndAnswer()}
    </Form>
  );
};

export default AskBookForm;
