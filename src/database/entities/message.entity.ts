import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  DeleteDateColumn,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';
import { Session } from './session.entity';

export enum MessageSender {
  USER = 'user',
  ASSISTANT = 'assistant',
  SYSTEM = 'system',
}

@Entity('messages')
export class Message {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({
    type: 'enum',
    enum: MessageSender,
    default: MessageSender.USER,
  })
  sender: MessageSender;

  @Column('text')
  content: string;

  @Column({ nullable: true })
  sequenceNumber?: number;

  @Column({ nullable: true })
  tokenCount?: number;

  @Column('jsonb', { nullable: true })
  ragContext?: {
    query?: string;
    retrievedChunks?: Array<{
      content: string;
      chunk_id: string;
      similarity_score: number;
      metadata?: Record<string, any>;
    }>;
  };

  @Column('jsonb', { nullable: true })
  metadata?: Record<string, any>;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @DeleteDateColumn()
  deletedAt?: Date;

  // Relations
  @ManyToOne(() => User, user => user.messages)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  userId: string;

  @ManyToOne(() => Session, session => session.messages)
  @JoinColumn({ name: 'sessionId' })
  session: Session;

  @Column()
  sessionId: string;
} 