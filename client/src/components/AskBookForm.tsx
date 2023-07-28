import React, { useState } from "react";
import { TypeAnimation } from 'react-type-animation';
import { GridLoader } from "react-spinners";
import { Button, Col, Form, Input, Row } from 'reactstrap';
import './styles/AskBookForm.scss';
import axios from 'axios';

const AskBookForm: React.FC = () => {
  const [answer, setAnswer] = useState('');
  const [isAnswering, setIsAnswering] = useState(false);
  const [bookQuestion, setBookQuestion] = useState('');

  function handleBookQuestionEdit(event: React.ChangeEvent<HTMLInputElement>) {
    setBookQuestion((prev) => event.target.value);
  }

  const handleAsk = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setIsAnswering(true);
    const response = await axios.post('/ask', {
      question: event.currentTarget.bookQuestion.value
    });
    setAnswer(response.data.answer);
    setIsAnswering(false);
  }

  const handleFeelingLucky = async (event: React.MouseEvent<HTMLButtonElement, MouseEvent>) => {
    event.preventDefault();
    const options = [
      'What is a minimalist entrepreneur?',
      'What is your definition of community?',
      'How do I decide what kind of business I should start?'
    ],
    random = ~~(Math.random() * options.length);
    setBookQuestion(options[random]);
    setIsAnswering(true);
    const response = await axios.post('/ask', {
      question: options[random]
    });
    setAnswer(response.data.answer);
    setIsAnswering(false);
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
              <TypeAnimation sequence={[answer]} wrapper="span" />
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
        <>
          <Row className="mt-3">
            <Col>
              <GridLoader
                loading={isAnswering}
                size={8}
                aria-label="Loading Spinner"
                className="mx-auto"
                data-testid="loader"
              />
            </Col>
          </Row>
          <Row className="mt-3">
            <Col>
              <Button type="submit" className="me-1">Ask Question</Button>
              <Button type="button" className="ms-1" onClick={handleFeelingLucky}>I'm Feeling Lucky</Button>
            </Col>
          </Row>
        </>
      )
    }
  }

  return (
    <Form className="askBookFormContainer" onSubmit={handleAsk}>
      <Row>
        <Input name="bookQuestion" value={bookQuestion} onChange={handleBookQuestionEdit} type="textarea" />
      </Row>
      {renderButtonsAndAnswer()}
    </Form>
  );
};

export default AskBookForm;
