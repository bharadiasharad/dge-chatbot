import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Session } from '../../database/entities';

@Injectable()
export class SessionsService {
  constructor(
    @InjectRepository(Session)
    private sessionRepository: Repository<Session>,
  ) {}

  async create(userId: string, title: string, description?: string): Promise<Session> {
    const session = this.sessionRepository.create({
      userId,
      title,
      description,
    });
    return this.sessionRepository.save(session);
  }

  async findAll(userId: string): Promise<Session[]> {
    return this.sessionRepository.find({
      where: { userId },
      order: { updatedAt: 'DESC' },
    });
  }

  async findOne(id: string, userId: string): Promise<Session> {
    const session = await this.sessionRepository.findOne({
      where: { id, userId },
    });
    if (!session) {
      throw new NotFoundException('Session not found');
    }
    return session;
  }

  async update(id: string, userId: string, updates: Partial<Session>): Promise<Session> {
    const session = await this.findOne(id, userId);
    Object.assign(session, updates);
    return this.sessionRepository.save(session);
  }

  async remove(id: string, userId: string): Promise<void> {
    const session = await this.findOne(id, userId);
    await this.sessionRepository.softRemove(session);
  }

  async rename(id: string, userId: string, title: string): Promise<Session> {
    return this.update(id, userId, { title });
  }

  async toggleFavorite(id: string, userId: string): Promise<Session> {
    const session = await this.findOne(id, userId);
    session.isFavorite = !session.isFavorite;
    return this.sessionRepository.save(session);
  }
} 