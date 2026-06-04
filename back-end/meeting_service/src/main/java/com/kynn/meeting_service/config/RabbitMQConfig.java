package com.kynn.meeting_service.config;

import org.springframework.amqp.core.Queue;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMQConfig {

  public static final String QUEUE_TRANSCRIPTION_REQUEST = "transcription.request";
  public static final String QUEUE_TRANSCRIPTION_RESULT = "transcription.result";

  @Bean
  public Queue transcriptionRequestQueue() {
    return new Queue(QUEUE_TRANSCRIPTION_REQUEST, true); // durable = true
  }

  @Bean
  public Queue transcriptionResultQueue() {
    return new Queue(QUEUE_TRANSCRIPTION_RESULT, true);
  }

  @Bean
  public MessageConverter jsonMessageConverter() {
    return new Jackson2JsonMessageConverter();
  }

  @Bean
  public RabbitTemplate rabbitTemplate(ConnectionFactory connectionFactory) {
    RabbitTemplate template = new RabbitTemplate(connectionFactory);
    template.setMessageConverter(jsonMessageConverter());
    return template;
  }
}