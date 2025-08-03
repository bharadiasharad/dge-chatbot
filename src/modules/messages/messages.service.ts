import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Message, MessageSender } from '../../database/entities';

@Injectable()
export class MessagesService {
  constructor(
    @InjectRepository(Message)
    private messageRepository: Repository<Message>,
  ) {}

  async create(userId: string, sessionId: string, messageData: {
    sender: MessageSender;
    content: string;
    ragContext?: any;
    tokenCount?: number;
    metadata?: any;
  }): Promise<Message> {
    const message = this.messageRepository.create({
      userId,
      sessionId,
      ...messageData,
    });
    return this.messageRepository.save(message);
  }

  async findBySession(sessionId: string, userId: string): Promise<Message[]> {
    return this.messageRepository.find({
      where: { sessionId, userId },
      order: { createdAt: 'ASC' },
    });
  }
} 